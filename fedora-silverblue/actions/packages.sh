#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Packages"

taskItem "upgrading base image"
rpm-ostree upgrade

taskItem "removing unneeded packages"
sudo rpm-ostree override remove \
  firefox \
  firefox-langpacks \
  toolbox

taskItem "adding new packages"
ostreeInstall \
  adw-gtk3-theme \
  distrobox \
  steam-devices
