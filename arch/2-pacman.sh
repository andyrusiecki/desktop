#!/bin/bash

# Update pacman config (https://man.archlinux.org/man/pacman.conf.5)
# - enabling parallel downloads (defaults to 5)
sudo sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf

# - enabling multilib repo
sudo sed -i '/\[multilib\]/,+1 s/#//' /etc/pacman.conf

# - enabling color output
sudo sed -i '/Color/s/^#//g' /etc/pacman.conf

# Install cache and mirrorlist utils
sudo pacman -S --noconfirm --needed pacman-contrib reflector

# enable paccache timer
# - runs every week
# - deletes all cached versions of installed and uninstalled packages, except for the most recent three
sudo systemctl enable paccache.timer

# Update pacman mirrorlist (https://wiki.archlinux.org/title/Reflector)
sudo reflector --save /etc/pacman.d/mirrorlist --protocol https --country "United States" --latest 5 --sort age

# enable reflector service
root=$(dirname $(realpath $0))
sudo mkdir -p $root/dotfiles/etc/xdg/reflector
sudo cp $root/dotfiles/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/

sudo systemctl enable reflector.service
