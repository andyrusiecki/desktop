#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Tailscale"

taskItem "installing tailscale"
ostreeInstall --apply-live tailscale

taskItem "enabling tailscale"
sudo systemctl enable --now tailscaled
sudo tailscale set --operator=$USER
