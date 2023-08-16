#!/bin/bash

root=$(dirname $(realpath $0))

packages=(
  adwaita-cursors
  adwaita-icon-theme
  adwaita-qt5
  adwaita-qt6
  adw-gtk3
  aurutils
  btop
  dunst
  gnome-keyring
  grim
  gvfs
  gvfs-smb
  hyprland
  kitty
  libnotify
  light
  nautilus
  nerd-fonts-meta
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
  swaylock-effects
  ttf-ms-fonts
  waybar
  wofi
  wttrbar
  xorg-xwayland
  xdg-desktop-portal-gtk
  xdg-desktop-portal-hyprland
  xdg-user-dirs
)

# needed for wttrbar package install
cp -r $root/dotfiles/dot_cargo ~/.cargo

paru -S --noconfirm --needed ${packages[@]}

sudo systemctl enable sddm.service

# add user to video group for light
sudo usermod -aG video $USER

mkdir -p ~/.config
cp -r $root/dotfiles/dot_config/dunst ~/.config/
cp -r $root/dotfiles/dot_config/hypr ~/.config/
cp -r $root/dotfiles/dot_config/kitty ~/.config/
cp -r $root/dotfiles/dot_config/swaylock ~/.config/
cp -r $root/dotfiles/dot_config/wal ~/.config/
cp -r $root/dotfiles/dot_config/waybar ~/.config/

mkdir -p ~/.local
cp -r $root/dotfiles/dot_local/bin ~/.local/

fish -c 'fish_add_path ~/.local/bin'

# hide gtk close buttons
gsettings set org.gnome.desktop.wm.preferences button-layout :


