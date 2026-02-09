#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Network"

taskItem "multicast DNS"
pacmanInstall avahi nss-mdns

# Disable multicast dns in resolved. Avahi will provide this for better network printer discovery
sudo mkdir -p /etc/systemd/resolved.conf.d
echo "[Resolve]\nMulticastDNS=no" | sudo tee /etc/systemd/resolved.conf.d/10-disable-multicast.conf

sudo sed -i 's/^hosts:.*/hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files myhostname dns/' /etc/nsswitch.conf

sudo systemctl enable --now avahi-daemon.service

taskItem "systemd-resolved"

sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
sudo systemctl enable --now systemd-resolved

taskItem "firewall"
pacmanInstall ufw gufw

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo systemctl enable --now ufw
