#!/bin/bash

set -euo pipefail

basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Packages"

taskItem "upgrading base image"
rpm-ostree upgrade

taskItem "enabling staging of new images"
echo "AutomaticUpdatePolicy=stage" | sudo tee --append /etc/rpm-ostreed.conf
echo "Recommends=false" | sudo tee --append /etc/rpm-ostreed.conf

taskItem "removing unneeded packages"
sudo rpm-ostree override remove \
  fedora-workstation-repositories \
  firefox \
  firefox-langpacks \
  toolbox

taskItem "adding new packages"
ostreeInstall --apply-live \
  adw-gtk3-theme \
  btop \
  cabextract \
  distrobox \
  fastfetch \
  fish \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-caffeine \
  gnome-shell-extension-just-perfection \
  neovim \
  podman-compose \
  podman-tui \
  ranger \
  starship \
  steam-devices
