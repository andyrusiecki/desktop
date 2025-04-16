#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Applications"

taskItem "removing unneeded apps"
sudo dnf --assumeyes remove \
  firefox \
  gnome-abrt \
  abrt \
  toolbox

taskItem "installing new apps"
dnfInstall \
  adw-gtk3-theme \
  discord \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-caffeine \
  gnome-shell-extension-just-perfection \
  gnome-tweaks \
  mangohud \
  steam \
  steam-devices
