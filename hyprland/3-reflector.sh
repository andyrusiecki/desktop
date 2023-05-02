#!/bin/bash

sudo pacman -S --noconfirm --needed reflector

# Update pacman mirrorlist (https://wiki.archlinux.org/title/Reflector)
sudo reflector --save /etc/pacman.d/mirrorlist --protocol https --country "United States" --latest 5 --sort age

# add reflector service
root=$(dirname $(realpath $0))
sudo mkdir -p $root/dotfiles/etc/xdg/reflector
sudo cp $root/dotfiles/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/

sudo systemctl enable reflector.service
