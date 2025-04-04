#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Snapshots"

taskItem "installing packages"
pacmanInstall \
  snap-pac \
  snapper

taskItem "creating root snapper config"
sudo mkdir -p /etc/snapper/configs/
sudo install -Dm640 $basedir/../../shared/files/snapper-root-config /etc/snapper/configs/root
sudo sed -i "s/\$USER/$USER/" /etc/snapper/configs/root

taskItem "enabling timers"
sudo systemctl enable snapper-boot.timer
sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable snapper-timeline.timer
