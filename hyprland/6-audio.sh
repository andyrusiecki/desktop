#!/bin/bash

# sound (https://github.com/archlinux/archinstall/blob/master/profiles/applications/pipewire.py)
sudo pacman -S --noconfirm --needed \
pipewire \
pipewire-alsa \
pipewire-jack \
pipewire-pulse \
gst-plugin-pipewire \
libpulse \
wireplumber

systemctl enable --user pipewire-pulse.service
