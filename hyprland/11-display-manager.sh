#!/bin/bash

sudo pacman -S --noconfirm --needed lightdm lightdm-slick-greeter

# Setup lightdm greeter
sudo sed -i '/greeter-session=/s/^$/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf

sudo systemctl enable lightdm.service
