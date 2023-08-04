#!/bin/bash

# ufw (https://wiki.archlinux.org/title/Uncomplicated_Firewall)
sudo pacman -S --noconfirm --needed \
gufw \
ufw

sudo systemctl enable ufw.service
