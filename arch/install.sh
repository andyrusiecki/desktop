#!/bin/bash

root=$(dirname $(realpath $0))

while getopts 'hu:d:p:' opt; do
  case "$opt" in
    u)
      arg="$OPTARG"
      if ! id -u $arg > /dev/null 2>&1; then
        echo "User $arg does not exist!"
        exit 0
      fi
      user="$arg"
      ;;

    d)
      arg="$OPTARG"
      case "$arg" in
        framework|vm)
          device="$arg"
          ;;
        *)
          echo "Device $arg not recognized!"
          echo "Available devices are: framework, vm"
          exit 0
          ;;
      esac
      ;;

    p)
      arg="$OPTARG"
      case "$arg" in
        gnome|hyprland|all)
          profile="$arg"
          ;;
        *)
          echo "Profile $arg not recognized!"
          echo "Available profiles are: gnome, hyprland, all"
          exit 0
          ;;
      esac
      ;;

    ?|h)
      echo "Usage: $(basename $0) [-u user] [-d device] [-p profile]"
      echo -e "-u <user>\t user to run install script as"
      echo -e "-d <device>\t runs additional tasks based on the device (available devices: framework, vm)"
      echo -e "-p <profile>\t runs additional tasks based on the profile (available profiles: gnome, hyprland)\n"
      exit 1
      ;;
  esac
done

if [[ "$(id -u)" != "0" ]]; then
    echo  "This script must be run under the 'root' user!"
    exit 0
fi

if test -z "$user"; then
  echo "User option (-u <user>) is required!"
  exit 0
fi

if test -z "$device"; then
  echo "Device option (-d <device>) is required!"
  exit 0
fi

if test -z "$profile"; then
  echo "Profile option (-p <profile>) is required!"
  exit 0
fi

# ensure user directories exist
sudo -u $user mkdir -p /home/$user/.config
sudo -u $user mkdir -p /home/$user/.local/bin

echo -ne "
======== 1. pacman ========
"

# Update pacman config (https://man.archlinux.org/man/pacman.conf.5)
# - enabling parallel downloads (defaults to 5)
sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf

# - enabling multilib repo
sed -i '/\[multilib\]/,+1 s/#//' /etc/pacman.conf

# - enabling color output
sed -i '/Color/s/^#//g' /etc/pacman.conf

# Update arch keyring
pacman -Sy --noconfirm archlinux-keyring

# Install cache and mirrorlist utils
pacman -Sy --noconfirm --needed pacman-contrib reflector

# enable paccache timer
# - runs every week
# - deletes all cached versions of installed and uninstalled packages, except for the most recent three
systemctl enable paccache.timer

# Update pacman mirrorlist (https://wiki.archlinux.org/title/Reflector)
reflector --age 48 --latest 20 --fastest 5 --sort rate --protocol https --country US --save /etc/pacman.d/mirrorlist

# enable reflector service
mkdir -p $root/dotfiles/etc/xdg/reflector
cp $root/dotfiles/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/

systemctl enable reflector.service

echo -ne "
======== 2. snapper ========
"

pacman -S --noconfirm --needed snapper snap-pac
umount /.snapshots
rm -r /.snapshots
snapper -c root create-config /

systemctl enable snapper-cleanup.timer
systemctl enable snapper-timeline.timer

echo -ne "
======== 3. base dependencies and services ========
"

pkgs=(
  # base
  nano
  vim
  openssh
  htop
  wget
  iwd
  wireless_tools
  wpa_supplicant
  smartmontools
  xdg-utils
  git

  # sound (https://github.com/archlinux/archinstall/blob/master/archinstall/default_profiles/applications/pipewire.py)
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-pulse
  gst-plugin-pipewire
  libpulse
  wireplumber

  # ufw (https://wiki.archlinux.org/title/Uncomplicated_Firewall)
  gufw
  ufw

  # bluetooth
  bluez
  bluez-utils

  # network discovery
  avahi-daemon

  # printing
  cups
)

pacman -S --noconfirm --needed ${pkgs[@]}

systemctl enable bluetooth.service
systemctl enable ufw.service
systemctl enable avahi-daemon.service
systemctl enable cups.service

sudo -u $user systemctl enable --user pipewire-pulse.service

echo -ne "
======== 4. plymouth and systemd-boot ========
"

pacman -S --noconfirm --needed plymouth

# add plymouth hook after "base udev"
sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf
mkinitcpio -P

# rename boot entries
mv /boot/loader/entries/*_linux.conf /boot/loader/entries/linux.conf
mv /boot/loader/entries/*_linux-fallback.conf /boot/loader/entries/linux-fallback.conf

mv /boot/loader/entries/*_linux-lts.conf /boot/loader/entries/linux-lts.conf
mv /boot/loader/entries/*_linux-lts-fallback.conf /boot/loader/entries/linux-lts-fallback.conf

# allow plymouth splash in boot entries
sed -i 's/^options .*$/& quiet splash/' /boot/loader/entries/linux.conf
sed -i 's/^options .*$/& quiet splash/' /boot/loader/entries/linux-lts.conf

# disable plymouth for fallback entries
sed -i 's/^options .*$/& plymouth.enable=0 disablehooks=plymouth/' /boot/loader/entries/linux-fallback.conf
sed -i 's/^options .*$/& plymouth.enable=0 disablehooks=plymouth/' /boot/loader/entries/linux-lts-fallback.conf

echo -ne "
======== 5. paru ========
"

# Install paru (https://github.com/Morganamilo/paru)
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git $tmp_dir/paru
(cd $tmp_dir/paru && makepkg --noconfirm --needed -si)
rm -rf $tmp_dir

sudo -u $user cp -r $root/dotfiles/dot_config/paru /home/$user/.config/

echo -ne "
======== 6. shell ========
"

pacman -S --noconfirm --needed fish starship

sudo -u $user cp -r $root/dotfiles/dot_config/fish /home/$user/.config/
sudo -u $user cp -r $root/dotfiles/dot_config/starship.toml /home/$user/.config/

sudo -u $user fish -c 'fish_add_path /home/$user/.local/bin'

# Change default shell to fish
chsh -s $(command -v fish) $user

echo -ne "
======== 7. development ========
"

pkgs=(
  aws-cli-v2
  distrobox
  docker-compose
  go
  jq
  k9s
  kubectl
  make
  podman
  podman-docker
)

pacman -S --noconfirm --needed ${pkgs[@]}

# install aws ecr helper from AUR
paru -S --noconfirm --needed amazon-ecr-credential-helper

sudo -u $user cp -r $root/dotfiles/dot_config/containers /home/$user/.config/
sudo -u $user cp -r $root/dotfiles/dot_docker /home/$user/.docker
sudo -u $user cp -r $root/dotfiles/dot_cargo /home/$user/.cargo

sudo -u $user systemctl enable --user podman.socket

echo -ne "
======== 8. profiles ========
"

if [ "$profile" = "gnome" ] || [ "$profile" = "all" ]; then
  pkgs=(
    gdm
    gnome
    gnome-boxes
    gnome-sound-recorder
    gnome-tweaks
    gnome-usage
    xdg-desktop-portal-gnome
  )

  pacman -S --noconfirm --needed ${packages[@]}

  aur_pkgs=(
    aurutils
    adw-gtk3
  )

  paru -S --noconfirm --needed ${packages[@]}

  systemctl enable gdm.service

  # gnome extensions
  extensions=(
    AlphabeticalAppGrid@stuarthayhurst
    appindicatorsupport@rgcjonas.gmail.com
    blur-my-shell@aunetx
    caffeine@patapon.info
    mediacontrols@cliffniff.github.com
    nightthemeswitcher@romainvigier.fr
    no-overview@fthx
    notification-banner-reloaded@marcinjakubowski.github.com
    pip-on-top@rafostar.github.com
    user-theme@gnome-shell-extensions.gcampax.github.com
    Vitals@CoreCoding.com
  )

  shell_version=$(gnome-shell --version | cut -d' ' -f3)

  for uuid in ${extensions[@]}
  do
    info_json=$(curl -sS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")
    download_url=$(echo $info_json | jq ".download_url" --raw-output)

    sudo -u $user gnome-extensions install "https://extensions.gnome.org$download_url"
    sudo -u $user gnome-extensions enable $uuid
  done

  # gnome dconf settings
  sudo -u $user gsettings set org.gnome.desktop.datetime automatic-timezone true

  sudo -u $user gsettings set org.gnome.desktop.interface clock-format "12h"
  sudo -u $user gsettings set org.gnome.desktop.interface clock-show-weekday true
  sudo -u $user gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
  sudo -u $user gsettings set org.gnome.desktop.interface font-hinting "slight"
  sudo -u $user gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<SHIFT><SUPER>1']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<SHIFT><SUPER>2']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<SHIFT><SUPER>3']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<SHIFT><SUPER>4']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<SHIFT><SUPER>5']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<SHIFT><SUPER>6']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<SHIFT><SUPER>7']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 "['<SHIFT><SUPER>8']"

  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<SUPER>1']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<SUPER>2']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<SUPER>3']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<SUPER>4']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<SUPER>5']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<SUPER>6']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<SUPER>7']"
  # sudo -u $user gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<SUPER>8']"

  sudo -u $user gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  sudo -u $user gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

  sudo -u $user gsettings set org.gnome.system.location enabled true
fi

if [ "$profile" = "hyprland" ] || [ "$profile" = "all" ]; then
  packages=(
    adwaita-cursors
    adwaita-icon-theme
    btop
    dunst
    gnome-keyring
    grim
    gvfs
    gvfs-afc
    gvfs-goa
    gvfs-google
    gvfs-gphoto2
    gvfs-mtp
    gvfs-nfs
    gvfs-smb
    hyprland
    kitty
    libnotify
    light
    nautilus
    noto-fonts
    pamixer
    pavucontrol
    polkit-gnome
    python-pywal
    qt5-wayland
    qt6-wayland
    sddm
    slurp
    swaybg
    swayidle
    waybar
    wofi
    xorg-xwayland
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-user-dirs
  )

  pacman -S --noconfirm --needed ${pkgs[@]}

  aur_pkgs=(
    adwaita-qt5
    adwaita-qt6
    adw-gtk3
    aurutils
    nerd-fonts-meta
    swaylock-effects
    ttf-ms-fonts
    wttrbar
  )

  paru -S --noconfirm --needed ${packages[@]}

  # install sddm if we don't already have gdm from gnome
  if [ "$profile" = "hyprland" ]; then
    pacman -S --noconfirm --needed sddm
    systemctl enable sddm.service
  fi

  # add user to video group for light
  usermod -aG video $user

  sudo -u $user cp -r $root/dotfiles/dot_config/dunst /home/$user/.config/
  sudo -u $user cp -r $root/dotfiles/dot_config/hypr /home/$user/.config/
  sudo -u $user cp -r $root/dotfiles/dot_config/kitty /home/$user/.config/
  sudo -u $user cp -r $root/dotfiles/dot_config/swaylock /home/$user/.config/
  sudo -u $user cp -r $root/dotfiles/dot_config/wal /home/$user/.config/
  sudo -u $user cp -r $root/dotfiles/dot_config/waybar /home/$user/.config/

  sudo -u $user cp -r $root/dotfiles/dot_local/bin/* /home/$user/.local/bin/

  # hide gtk close buttons
  sudo -u $user gsettings set org.gnome.desktop.wm.preferences button-layout :
fi

echo -ne "
======== 9. flatpak ========
"

flatpak_apps=(
  app/org.mozilla.firefox/x86_64/stable
  com.discordapp.Discord
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.slack.Slack
  com.spotify.Client
  com.valvesoftware.Steam
  com.valvesoftware.Steam.CompatibilityTool.Proton
  com.visualstudio.code
  md.obsidian.Obsidian
  org.freedesktop.Platform.VulkanLayer.gamescope
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.gtk.Gtk3theme.adw-gtk3-dark
  org.libreoffice.LibreOffice
  org.signal.Signal
  runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
  us.zoom.Zoom
)

pacman -S --noconfirm --needed flatpak

flatpak install --noninteractive ${flatpak_apps[@]}

# flatpak settings
flatpak override org.mozilla.firefox --env=MOZ_ENABLE_WAYLAND=1

if [ "$profile" = "gnome" ] || [ "$profile" = "all" ]; then
  flatpak install --noninteractive com.mattjakeman.ExtensionManager io.github.realmazharhussain.GdmSettings
fi

if [ "$profile" = "hyprland" ] || [ "$profile" = "all" ]; then
  flatpak install --noninteractive com.github.themix_project.Oomox

  # generate initial themes with Oomox
  sudo -u $user wal -i /home/$user/.config/hypr/wallpaper
  flatpak override com.github.themix_project.Oomox --filesystem=/home/$user/.cache/wal
  sudo -u $user flatpak run --command=oomox-cli com.github.themix_project.Oomox /home/$user/.cache/wal/colors-oomox -o pywal
fi

echo -ne "
======== 10. device ========
"

if [ "$device" = "framework" ]; then
  pkgs=(
    # cpu microcode
    intel-ucode

    # graphics drivers
    mesa
    libva-intel-driver
    intel-media-driver
    vulkan-intel

    # fingerprint reader
    fprintd
    imagemagick

    # power saving
    power-profiles-daemon
  )

  pacman -S --noconfirm --needed ${packages[@]}

  systemctl enable power-profiles-daemon.service

  # fixing brightness keys and screen freezes
  cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
fi

if [ "$device" = "vm" ]; then
  pacman -S --noconfirm --needed mesa xf86-video-vmware

  if [ "$profile" = "hyprland" ] || [ "$profile" = "all" ]; then
    sed -i 's/^Exec=.*$/Exec=env WLR_RENDERER_ALLOW_SOFTWARE=1 WLR_NO_HARDWARE_CURSORS=1 Hyprland/' /usr/share/wayland-sessions/hyprland.desktop
  fi
fi

echo -ne "
======== 11. final snapshot ========
"

snapper -c root create --description "Install Complete"

echo -ne "
Install Complete!

Please reboot
"
