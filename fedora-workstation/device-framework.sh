#!/bin/bash

root=$(dirname $(realpath $0))

# 1. tlp
sudo dnf -y install tlp tlp-rdw

# add config
sudo mkdir /etc/tlp.d
sudo cp $root/framework-tlp.conf /etc/tlp.d/50-framework.conf

# mask power-profiles-daemon
sudo systemctl stop power-profiles-daemon.service
sudo systemctl disable power-profiles-daemon.service
sudo systemctl mask power-profiles-daemon.service

# enmable tlp
sudo systemctl enable tlp
