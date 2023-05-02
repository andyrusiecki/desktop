#!/bin/bash

paru -S --noconfirm --needed \
adwaita-cursors \
adwaita-icon-theme \
btop \
dunst \
file-roller \
gnome-keyring \
grim \
gvfs \
gvfs-google \
gvfs-smb \
hyprland \
kitty \
libsecret \
light \
noto-fonts \
pacman-contrib \
pamixer \
pavucontrol \
polkit-gnome \
python-pywal \
qt5-wayland \
qt6-wayland \
sshfs \
slurp \
swappy \
swaybg \
swaylock-effects \
themix-full-git \
thunar \
thunar-archive-plugin \
thunar-volman \
ttf-ms-fonts \
ttf-roboto-mono-nerd \
waybar-hyprland \
wlogout \
wofi \
xdg-desktop-portal-hyprland \
xdg-user-dirs

root=$(dirname $(realpath $0))

mkdir ~/.config
cp -r $root/dotfiles/dot_config/dunst ~/.config/
cp -r $root/dotfiles/dot_config/hypr ~/.config/
cp -r $root/dotfiles/dot_config/kitty ~/.config/

mkdir -p ~/.local
cp -r $root/dotfiles/dot_local/bin ~/.local/

# generate initial themes
wal -i ~/.config/hypr/wallpaper
oomox-cli ~/.cache/wal/colors-oomox -o pywal
