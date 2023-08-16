#!/bin/bash

root=$(dirname $(realpath $0))

paru -S --noconfirm --needed mesa xf86-video-vmware sway xdg-desktop-portal-wlr

mkdir -p ~/.config
cp -r $root/dotfiles/dot_config/sway ~/.config/
