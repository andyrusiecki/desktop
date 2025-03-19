#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Tailscale"

taskItem "installing tailscale"
rpm-ostree install --assumeyes --apply-live tailscale

taskItem "enabling tailscale"
sudo systemctl enable tailscaled
tailscale set --operator=$USER
