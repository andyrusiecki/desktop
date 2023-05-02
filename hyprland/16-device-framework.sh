#!/bin/bash

paru -S --noconfirm --needed \
mesa \
libva-intel-driver \
intel-media-driver \
vulkan-intel \
fprintd \
imagemagick \
power-profiles-daemon

sudo systemctl enable power-profiles-daemon.service

# fixing brightness keys and screen freezes
root=$(dirname $(realpath $0))
sudo cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
