#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Applications"

taskItem "removing unneeded apps"
sudo dnf --assumeyes remove firefox gnome-abrt abrt

taskItem "installing new apps"
dnfInstall \
  adw-gtk3-theme \
  discord \
  gnome-tweaks \
  mangohud \
  nextcloud-client \
  steam \
  steam-devices
