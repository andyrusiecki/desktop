#!/bin/bash

# samba (https://wiki.archlinux.org/title/Samba)
sudo pacman -S --noconfirm --needed samba

root=$(dirname $(realpath $0))
sudo mkdir -p $root/dotfiles/etc/samba
sudo cp $root/dotfiles/etc/samba/smb.conf /etc/samba/

sudo systemctl enable smb.service

# add to firewall rules
sudo firewall-offline-cmd --add-service={samba,samba-client,samba-dc} --zone=home
