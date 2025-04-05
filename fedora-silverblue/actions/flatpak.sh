#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Flatpak"

taskItem "removing Fedora flatpak repo"

# Replace fedora flatpak repo with flathub (https://www.reddit.com/r/Fedora/comments/z2kk88/fedora_silverblue_replace_the_fedora_flatpak_repo/)
if ! flatpak remotes | grep --quiet flathub; then
  sudo flatpak remote-modify --no-filter --enable flathub
fi

if flatpak info org.fedoraproject.MediaWriter &>/dev/null; then
  flatpak remove --noninteractive --assumeyes org.fedoraproject.MediaWriter
fi

if flatpak remotes | grep --quiet fedora; then
  flatpak install --noninteractive --assumeyes --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
  sudo flatpak remote-delete fedora
fi

taskItem "installing apps"

flatpak_apps=(
  com.dec05eba.gpu_screen_recorder
  com.discordapp.Discord # Silverblue specific
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.nextcloud.desktopclient.nextcloud
  com.slack.Slack
  com.spotify.Client
  com.valvesoftware.Steam # Silverblue specific
  com.visualstudio.code # Silverblue specific
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
  org.libreoffice.LibreOffice
  org.mozilla.firefox
  org.signal.Signal
  us.zoom.Zoom
)

flatpak_runtimes=(
  org.gtk.Gtk3theme.adw-gtk3
  org.freedesktop.Platform.ffmpeg-full//23.08
)

flatpak install --app --noninteractive ${flatpak_apps[@]}
flatpak install --runtime --noninteractive ${flatpak_runtimes[@]}

