#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Tailscale"

taskItem "installing tailscale"
pacmanInstall tailscale

taskItem "have NetworkManager unmanage tailscale"
sudo echo -e "[keyfile]\nunmanaged-devices=interface-name:tailscale0\n" > /etc/NetworkManager/conf.d/99-tailscale.conf

taskItem "enabling tailscale"
sudo systemctl enable --now tailscaled
sudo tailscale set --operator=$USER
