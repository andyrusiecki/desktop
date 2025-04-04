#!/bin/bash

root=$(dirname $(realpath $0))

echo -ne "
======== 4. plymouth and systemd-boot ========
"

sudo pacman -S --noconfirm --needed plymouth

# add plymouth hook after "base udev"
sudo sed -i '/plymouth/! s/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# rename boot entries
sudo mv /boot/loader/entries/*_linux.conf /boot/loader/entries/linux.conf
sudo mv /boot/loader/entries/*_linux-fallback.conf /boot/loader/entries/linux-fallback.conf

sudo mv /boot/loader/entries/*_linux-lts.conf /boot/loader/entries/linux-lts.conf
sudo mv /boot/loader/entries/*_linux-lts-fallback.conf /boot/loader/entries/linux-lts-fallback.conf

# allow plymouth splash in boot entries
sudo sed -i 's/^options .*$/& quiet splash/' /boot/loader/entries/linux.conf
sudo sed -i 's/^options .*$/& quiet splash/' /boot/loader/entries/linux-lts.conf

# disable plymouth for fallback entries
sudo sed -i 's/^options .*$/& plymouth.enable=0 disablehooks=plymouth/' /boot/loader/entries/linux-fallback.conf
sudo sed -i 's/^options .*$/& plymouth.enable=0 disablehooks=plymouth/' /boot/loader/entries/linux-lts-fallback.conf
