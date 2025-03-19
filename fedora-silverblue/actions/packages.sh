#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Packages"

taskItem "upgrading base image"
rpm-ostree upgrade

taskItem "removing unneeded packages"
rpm-ostree remove \
  --assumeyes \
  firefox \
  firefox-langpacks \
  toolbox

taskItem "adding new packages"
rpm-ostree install \
  --assumeyes \
  --install adw-gtk3-theme \
  --install distrobox \
#  --install fish \
#  --install neovim \
#  --install starship \
  --install steam-devices \
#  --install tailscale
