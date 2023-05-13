#!/bin/bash

packages=(
  mesa
  # libva-intel-driver
  intel-media-driver
  vulkan-intel
  fprintd
  imagemagick
  # power-profiles-daemon
  auto-cpufreq
  powertop
)

paru -S --noconfirm --needed ${packages[@]}

sudo systemctl enable auto-cpufreq.service
# sudo systemctl enable power-profiles-daemon.service

sudo cp $root/dotfiles/etc/systemd/system/powertop.service /etc/systemd/system/
sudo systemctl enable powertop.service

# fixing brightness keys and screen freezes
root=$(dirname $(realpath $0))
sudo cp $root/dotfiles/etc/modprobe.d/* /etc/modprobe.d/
