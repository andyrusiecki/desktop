#!/bin/bash

root=$(dirname $(realpath $0))

while getopts 'hd:p:' opt; do
  case "$opt" in
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
      echo -e "-d <device>\t runs additional tasks based on the device (available devices: framework, vm)"
      echo -e "-p <profile>\t runs additional tasks based on the profile (available profiles: gnome, hyprland)\n"
      exit 1
      ;;
  esac
done

if [[ "$(id -u)" = "0" ]]; then
    echo  "This script must be run under a normal user!"
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
mkdir -p ~/.config
mkdir -p ~/.local/bin

echo -ne "
======== 1. pacman ========
"

# Update pacman config (https://man.archlinux.org/man/pacman.conf.5)
# - enabling parallel downloads (defaults to 5)
sudo sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf

# - enabling multilib repo
sudo sed -i '/\[multilib\]/,+1 s/#//' /etc/pacman.conf

# - enabling color output
sudo sed -i '/Color/s/^#//g' /etc/pacman.conf

# Update arch keyring
sudo pacman -Sy --noconfirm archlinux-keyring

# Install cache and mirrorlist utils
sudo pacman -Sy --noconfirm --needed pacman-contrib reflector

# enable paccache timer
# - runs every week
# - deletes all cached versions of installed and uninstalled packages, except for the most recent three
sudo systemctl enable paccache.timer

# Update pacman mirrorlist (https://wiki.archlinux.org/title/Reflector)
sudo reflector --age 48 --latest 20 --fastest 5 --sort rate --protocol https --country US --save /etc/pacman.d/mirrorlist

# enable reflector service
sudo mkdir -p /etc/xdg/reflector
sudo cp $root/dotfiles/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/

sudo systemctl enable reflector.service

echo -ne "
======== 2. snapper ========
"

sudo pacman -S --noconfirm --needed snapper snap-pac
sudo mkdir -p /etc/snapper/configs/
sudo cp $root/dotfiles/etc/snapper/configs/root /etc/snapper/configs/

sudo mkdir -p /etc/conf.d/
sudo cp $root/dotfiles/etc/conf.d/snapper /etc/conf.d/

sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable snapper-timeline.timer

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
  avahi

  # printing
  cups
)

sudo pacman -S --noconfirm --needed ${pkgs[@]}

sudo systemctl enable bluetooth.service
sudo systemctl enable ufw.service
sudo systemctl enable avahi-daemon.service
sudo systemctl enable cups.service

systemctl enable --user pipewire-pulse.service

echo -ne "
======== 4. plymouth and systemd-boot ========
"

sudo pacman -S --noconfirm --needed plymouth

# add plymouth hook after "base udev"
sudo sed -i 's/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# rename boot entries
sudo mv /boot/loader/entries/*_linux.conf /boot/loader/entries/linux.conf
sudo mv /boot/loader/entries/*_linux-fallback.conf /boot/loader/entries/linux-fallback.conf

sudo mv /boot/loader/entries/*_linux-lts.conf /boot/loader/entries/linux-lts.conf
sudo mv /boot/loader/entries/*_linux-lts-fallback.conf /boot/loader/entries/linux-lts-fallback.conf

# allow plymouth splash in boot entries
sudo sed -i 's/^options .*$/& quiet splash/' /boot/loader/entries/linux.conf
sudo sed -i 's/^options .*$/& quiet splash/' /boot/loader/entries/linux-lts.conf

# disable plymouth for fallback entries
sudo sed -i 's/^options .*$/& plymouth.enable=0 disablehooks=plymouth/' /boot/loader/entries/linux-fallback.conf
sudo sed -i 's/^options .*$/& plymouth.enable=0 disablehooks=plymouth/' /boot/loader/entries/linux-lts-fallback.conf

echo -ne "
======== 5. paru ========
"

# Install paru (https://github.com/Morganamilo/paru)
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git $tmp_dir/paru
(cd $tmp_dir/paru && makepkg --noconfirm --needed -si)
rm -rf $tmp_dir

cp -r $root/dotfiles/dot_config/paru ~/.config/

echo -ne "
======== 6. shell ========
"

sudo pacman -S --noconfirm --needed fish starship

cp -r $root/dotfiles/dot_config/fish ~/.config/
cp -r $root/dotfiles/dot_config/starship.toml ~/.config/

fish -c 'fish_add_path ~/.local/bin'

# Change default shell to fish
sudo chsh -s $(command -v fish) $USER

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

sudo pacman -S --noconfirm --needed ${pkgs[@]}

# install aws ecr helper from AUR
paru -S --noconfirm --needed amazon-ecr-credential-helper

cp -r $root/dotfiles/dot_config/containers ~/.config/
cp -r $root/dotfiles/dot_docker ~/.docker
cp -r $root/dotfiles/dot_cargo ~/.cargo

systemctl enable --user podman.socket

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

  sudo pacman -S --noconfirm --needed ${packages[@]}

  aur_pkgs=(
    aurutils
    adw-gtk3
  )

  paru -S --noconfirm --needed ${packages[@]}

  sudo systemctl enable gdm.service

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

    gnome-extensions install "https://extensions.gnome.org$download_url"
    gnome-extensions enable $uuid
  done

  # gnome dconf settings
  gsettings set org.gnome.desktop.datetime automatic-timezone true

  gsettings set org.gnome.desktop.interface clock-format "12h"
  gsettings set org.gnome.desktop.interface clock-show-weekday true
  gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
  gsettings set org.gnome.desktop.interface font-hinting "slight"
  gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<SHIFT><SUPER>1']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<SHIFT><SUPER>2']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<SHIFT><SUPER>3']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<SHIFT><SUPER>4']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<SHIFT><SUPER>5']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<SHIFT><SUPER>6']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<SHIFT><SUPER>7']"
  # gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 "['<SHIFT><SUPER>8']"

  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<SUPER>1']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<SUPER>2']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<SUPER>3']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<SUPER>4']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<SUPER>5']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<SUPER>6']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<SUPER>7']"
  # gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<SUPER>8']"

  gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

  gsettings set org.gnome.system.location enabled true
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

  sudo pacman -S --noconfirm --needed ${pkgs[@]}

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
    sudo pacman -S --noconfirm --needed sddm
    sudo systemctl enable sddm.service
  fi

  # add user to video group for light
  sudo usermod -aG video $USER

  cp -r $root/dotfiles/dot_config/dunst ~/.config/
  cp -r $root/dotfiles/dot_config/hypr ~/.config/
  cp -r $root/dotfiles/dot_config/kitty ~/.config/
  cp -r $root/dotfiles/dot_config/swaylock ~/.config/
  cp -r $root/dotfiles/dot_config/wal ~/.config/
  cp -r $root/dotfiles/dot_config/waybar ~/.config/

  cp -r $root/dotfiles/dot_local/bin/* ~/.local/bin/

  # hide gtk close buttons
  if [ "$profile" = "hyprland" ]; then
    gsettings set org.gnome.desktop.wm.preferences button-layout :
  fi
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

sudo pacman -S --noconfirm --needed flatpak

flatpak install --noninteractive ${flatpak_apps[@]}

# flatpak settings
sudo flatpak override org.mozilla.firefox --env=MOZ_ENABLE_WAYLAND=1

if [ "$profile" = "gnome" ] || [ "$profile" = "all" ]; then
  flatpak install --noninteractive com.mattjakeman.ExtensionManager io.github.realmazharhussain.GdmSettings
fi

if [ "$profile" = "hyprland" ] || [ "$profile" = "all" ]; then
  flatpak install --noninteractive com.github.themix_project.Oomox

  # generate initial themes with Oomox
  wal -i ~/.config/hypr/wallpaper
  sudo flatpak override com.github.themix_project.Oomox --filesystem=~/.cache/wal
  flatpak run --command=oomox-cli com.github.themix_project.Oomox ~/.cache/wal/colors-oomox -o pywal
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

  sudo pacman -S --noconfirm --needed ${packages[@]}

  sudo systemctl enable power-profiles-daemon.service

  # fixing brightness keys and screen freezes
  sudo cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
fi

if [ "$device" = "vm" ]; then
  sudo pacman -S --noconfirm --needed mesa xf86-video-vmware

  if [ "$profile" = "hyprland" ] || [ "$profile" = "all" ]; then
    sudo sed -i 's/^Exec=.*$/Exec=env WLR_RENDERER_ALLOW_SOFTWARE=1 WLR_NO_HARDWARE_CURSORS=1 Hyprland/' /usr/share/wayland-sessions/hyprland.desktop
  fi
fi

echo -ne "
======== 11. final snapshot ========
"

sudo snapper -c root create --description "Install Complete"

echo -ne "
Install Complete!

Please reboot
"
