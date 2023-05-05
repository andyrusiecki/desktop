#!/bin/bash

flatpak_apps=(
  app/org.mozilla.firefox/x86_64/stable
  com.discordapp.Discord
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  com.usebottles.bottles
  com.valvesoftware.Steam
  com.valvesoftware.Steam.CompatibilityTool.Proton
  com.valvesoftware.Steam.Utility.gamescope
  io.github.realmazharhussain.GdmSettings
  net.cozic.joplin_desktop
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.libreoffice.LibreOffice
  org.signal.Signal
  runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
  us.zoom.Zoom
)

flatpak install --noninteractive ${flatpak_apps[@]}
