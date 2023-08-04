#!/bin/bash

# printing (https://wiki.archlinux.org/title/CUPS)
sudo pacman -S --noconfirm --needed cups cups-pdf

sudo systemctl enable cups.socket
