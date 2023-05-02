#!/bin/bash

while getopts 'hd:' opt; do
  case "$opt" in
    d)
      arg="$OPTARG"
      if [[ "$arg" == "framework" ]]; then
        device="$arg"
      fi
      ;;

    ?|h)
      echo "Usage: $(basename $0) [-v] [-d device]"
      echo -e "-d <device>\t runs additional tasks based on the device (available devices: framework)"
      exit 1
      ;;
  esac
done

root=$(dirname $(realpath $0))

packages=(
  # base
  linux-lts
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

  # bluetooth
  bluez
  bluez-utils

  # fonts
  noto-fonts
  ttf-roboto-mono-nerd
  ttf-ms-fonts

  # firewall (https://wiki.archlinux.org/title/Firewalld)
  firewalld

  # printing (https://wiki.archlinux.org/title/CUPS)
  cups
  cups-pdf

  # samba (https://wiki.archlinux.org/title/Samba)
  samba

  # sound (https://github.com/archlinux/archinstall/blob/master/profiles/applications/pipewire.py)
  pipewire
  pipewire-alsa
  pipewire-jack
  pipewire-pulse
  gst-plugin-pipewire
  libpulse
  wireplumber

  # shell
  fish
  starship

  # development
  amazon-ecr-credential-helper
  aws-cli-v2
  docker-compose
  go
  jq
  kubectl
  make
  podman
  podman-docker

  # hyprland
  adwaita-cursors
  adwaita-icon-theme
  btop
  dunst
  file-roller
  gnome-keyring
  grim
  gvfs
  gvfs-google
  gvfs-smb
  hyprland
  kitty
  libsecret
  light
  lightdm
  lightdm-slick-greeter
  nwg-look
  pacman-contrib
  pamixer
  pavucontrol
  polkit-gnome
  python-pywal
  qt5-wayland
  qt6-wayland
  sshfs
  slurp
  swappy
  swaybg
  swaylock-effects
  themix-full-git
  thunar
  thunar-archive-plugin
  thunar-volman
  waybar-hyprland
  wlogout
  wofi
  xdg-desktop-portal-hyprland
  xdg-user-dirs

  # flatpak
  flatpak

  # Other applications
  firefox
  visual-studio-code-bin
)
systemd_services_root=(
  # snapper
  snapper-cleanup.timer
  snapper-timeline.timer

  # mirrorlist
  reflector.service

  # bluetooth
  bluetooth.service

  # firewall
  firewalld.service

  # printing
  cups.service

  # samba
  smb.service
  nmb.service

  # containers
  podman.socket

  # display manager
  lightdm.service
)
systemd_services_user=(
  # sound
  pipewire-pulse.service
)

job="Hyprland Install"
echo "Starting $job..."

# Setup snapper and create a snapshot (https://www.reddit.com/r/Fedora/comments/n1ekg0/comment/gwfxvhc/?utm_source=reddit&utm_medium=web2x&context=3)
sudo pacman -S --noconfirm --needed snapper
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /

sudo snapper -c root create --description "Before Snapshot: $job"

# Update pacman config (https://man.archlinux.org/man/pacman.conf.5)
# - enabling parallel downloads (defaults to 5)
sudo sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf

# - enabling multilib repo
sudo sed -i '/\[multilib\]/,+1 s/#//' /etc/pacman.conf

# Update package repos and existing packages
sudo pacman -Syu --noconfirm

# Install initial packages
sudo pacman -S --noconfirm --needed bat git reflector

# Update pacman mirrorlist (https://wiki.archlinux.org/title/Reflector)
sudo reflector --save /etc/pacman.d/mirrorlist --protocol https --country "United States" --latest 5 --sort age

# Install paru (https://github.com/Morganamilo/paru)
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git $tmp_dir/paru
(cd $tmp_dir/paru && makepkg --noconfirm --needed -si)
rm -rf $tmp_dir

# 8. Device
if [[ $device == "framework" ]]; then
  packages+=(
    # graphics
    mesa
    libva-intel-driver
    intel-media-driver
    vulkan-intel

    # fingerprint reader
    fprintd
    imagemagick

    # power management
    power-profiles-daemon
  )

  systemd_services_root+=(
    power-profiles-daemon.service
  )

  # fixing brightness keys and screen freezes
  sudo cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
fi

# Install packages
paru -S --noconfirm --needed ${packages[@]}

# Copy config files
cp -r $root/dotfiles/dot_config/* ~/.config/
cp -r $root/dotfiles/dot_docker ~/.docker

sudo cp $root/dotfiles/etc/samba/smb.conf /etc/samba/
sudo cp $root/dotfiles/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/

# Change default shell to fish
sudo chsh -s $(command -v fish) $USER

# Setup lightdm greeter
sudo sed -i '/greeter-session=/s/^$/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf

# Enable systemd services
for i in ${systemd_services_root[@]}
do
	sudo systemctl enable $i
done

for i in ${systemd_services_user[@]}
do
	systemctl enable --user $i
done

# 14. Create Snapshot
sudo snapper -c root create --description "After Snapshot: $job"

# Done
echo -e "\n$job Complete!\n"

echo -n "Restarting in "
for i in {5..1}
do
  echo -n "$i..."
  sleep 1
done

systemctl reboot
