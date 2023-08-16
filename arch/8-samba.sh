#!/bin/bash

echo "not sure how necessary this file is for client access"
exit

# samba (https://wiki.archlinux.org/title/Samba)
sudo pacman -S --noconfirm --needed samba

root=$(dirname $(realpath $0))
sudo mkdir -p $root/dotfiles/etc/samba
sudo cp $root/dotfiles/etc/samba/smb.conf /etc/samba/

sudo systemctl enable smb.service
sudo systemctl enable nmb.service
sudo systemctl enable avahi-daemon.service

