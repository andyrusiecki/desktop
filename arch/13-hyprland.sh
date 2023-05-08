#!/bin/bash

packages=(
  adwaita-cursors
  adwaita-icon-theme
  aurutils
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
  noto-fonts
  pamixer
  pavucontrol
  polkit-gnome
  python-pywal
  qt5-wayland
  qt6-wayland
  sddm-git
  sshfs
  slurp
  swappy
  swaybg
  swaylock-effects
  themix-full-git
  thunar
  thunar-archive-plugin
  thunar-volman
  ttf-ms-fonts
  ttf-roboto-mono-nerd
  waybar-hyprland
  wlogout
  wofi
  xdg-desktop-portal-hyprland
  xdg-user-dirs
)

paru -S --noconfirm --needed ${packages[@]}

sudo systemctl enable sddm.service

# add user to video group for light
sudo usermod -aG video $USER

root=$(dirname $(realpath $0))

mkdir ~/.config
cp -r $root/dotfiles/dot_config/dunst ~/.config/
cp -r $root/dotfiles/dot_config/hypr ~/.config/
cp -r $root/dotfiles/dot_config/kitty ~/.config/
cp -r $root/dotfiles/dot_config/wal ~/.config/
cp -r $root/dotfiles/dot_config/waybar ~/.config/

mkdir -p ~/.local
cp -r $root/dotfiles/dot_local/bin ~/.local/

fish -c 'fish_add_path ~/.local/bin'

# generate initial themes
wal -i ~/.config/hypr/wallpaper
oomox-cli ~/.cache/wal/colors-oomox -o pywal
