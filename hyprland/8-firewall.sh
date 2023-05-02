#!/bin/bash

# firewall (https://wiki.archlinux.org/title/Firewalld)
sudo pacman -S --noconfirm --needed firewalld

sudo systemctl enable firewalld.service
