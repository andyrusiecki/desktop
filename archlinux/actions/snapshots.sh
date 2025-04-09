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
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sudo mkdir /.snapshots
sudo mount -a

taskItem "enabling timers"
sudo systemctl enable snapper-boot.timer
sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable snapper-timeline.timer
