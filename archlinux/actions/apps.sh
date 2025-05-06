#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Applications"
taskItem "installing packages"
pacmanInstall \
  adw-gtk-theme \
  celluloid \
  discord \
  firefox \
  gnome-boxes \
  gnome-tweaks \
  google-chrome \
  libreoffice-fresh \
  mission-center \
  nautilus-python \
  nextcloud-client \
  obsidian \
  pika-backup \
  signal-desktop

taskItem "installing flatpaks"
flatpak_apps=(
  com.getpostman.Postman
  com.github.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  dev.qwery.AddWater
  io.github.giantpinkrobots.flatsweep
  io.github.realmazharhussain.GdmSettings
  us.zoom.Zoom
)

flatpak_runtimes=(
  org.gtk.Gtk3theme.adw-gtk3
)

flatpak install --app --noninteractive ${flatpak_apps[@]}
flatpak install --runtime --noninteractive ${flatpak_runtimes[@]}
