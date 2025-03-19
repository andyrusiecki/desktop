#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Repositories"

taskItem "adding repositories"
sudo curl https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora -o /etc/yum.repos.d/starship.repo
sudo curl https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo
