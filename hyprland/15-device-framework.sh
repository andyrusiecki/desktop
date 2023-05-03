#!/bin/bash

paru -S --noconfirm --needed \
mesa \
libva-intel-driver \
intel-media-driver \
vulkan-intel \
fprintd \
imagemagick \
auto-cpufreq

sudo systemctl enable auto-cpufreq.service

# fixing brightness keys and screen freezes
root=$(dirname $(realpath $0))
sudo cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
