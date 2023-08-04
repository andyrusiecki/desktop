#!/bin/bash

root=$(dirname $(realpath $0))

packages=(
  mesa
  intel-media-driver
  vulkan-intel
  fprintd
  imagemagick
  tlp
)

paru -S --noconfirm --needed ${packages[@]}

sudo cp $root/dotfiles/etc/tlp.conf /etc/
sudo systemctl enable tlp.service

# fixing brightness keys and screen freezes
sudo cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
