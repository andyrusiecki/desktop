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
  sddm
  sshfs
  slurp
  swappy
  swaybg
  swaylock-effects
  thunar
  thunar-archive-plugin
  thunar-volman
  ttf-ms-fonts
  ttf-roboto-mono-nerd
  waybar
  wlogout
  wofi
  wttrbar
  xdg-desktop-portal-hyprland
  xdg-user-dirs
)

# needed for wttrbar package install
cp -r $root/dotfiles/dot_cargo ~/.cargo

paru -S --noconfirm --needed ${packages[@]}

sudo systemctl enable sddm.service

# add user to video group for light
sudo usermod -aG video $USER

root=$(dirname $(realpath $0))

mkdir ~/.config
cp -r $root/dotfiles/dot_config/dunst ~/.config/
cp -r $root/dotfiles/dot_config/hypr ~/.config/
cp -r $root/dotfiles/dot_config/kitty ~/.config/
cp -r $root/dotfiles/dot_config/swaylock ~/.config/
cp -r $root/dotfiles/dot_config/wal ~/.config/
cp -r $root/dotfiles/dot_config/waybar ~/.config/

mkdir ~/.local
cp -r $root/dotfiles/dot_local/bin ~/.local/

fish -c 'fish_add_path ~/.local/bin'

# generate initial themes
wal -i ~/.config/hypr/wallpaper
flatpak run --command=oomox-cli com.github.themix_project.Oomox ~/.cache/wal/colors-oomox -o pywal

