#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Flatpak"
taskItem "installing apps"

flatpak_apps=(
  com.dec05eba.gpu_screen_recorder
  com.getpostman.Postman
  com.github.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  dev.qwery.AddWater
  io.github.Foldex.AdwSteamGtk
  io.github.giantpinkrobots.flatsweep
  io.github.realmazharhussain.GdmSettings
  us.zoom.Zoom
)

flatpak_runtimes=(
  org.gtk.Gtk3theme.adw-gtk3
)

flatpak install --app --noninteractive ${flatpak_apps[@]}
flatpak install --runtime --noninteractive ${flatpak_runtimes[@]}
