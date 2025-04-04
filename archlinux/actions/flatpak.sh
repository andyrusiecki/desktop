#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Flatpak"
taskItem "installing apps"

flatpak_apps=(
  com.dec05eba.gpu_screen_recorder
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.nextcloud.desktopclient.nextcloud
  com.slack.Slack
  com.spotify.Client
  dev.qwery.AddWater
  io.github.Foldex.AdwSteamGtk
  io.github.celluloid_player.Celluloid
  io.github.giantpinkrobots.flatsweep
  io.github.realmazharhussain.GdmSettings
  io.missioncenter.MissionCenter
  md.obsidian.Obsidian
  me.dusansimic.DynamicWallpaper
  org.gnome.Boxes
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.libreoffice.LibreOffice
  org.mozilla.firefox
  org.signal.Signal
  us.zoom.Zoom
)

flatpak install --app --noninteractive ${flatpak_apps[@]}

# needed for firefox hw decode
flatpak install --runtime --noninteractive org.freedesktop.Platform.ffmpeg-full//23.08
