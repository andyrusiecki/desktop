#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Tailscale"

taskItem "installing tailscale"
dnfInstall tailscale

taskItem "enabling tailscale"
sudo systemctl enable tailscaled
sudo tailscale set --operator=$USER
