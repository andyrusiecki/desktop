#!/bin/bash

flatpak_apps=(
  app/org.mozilla.firefox/x86_64/stable
  com.discordapp.Discord
  com.getpostman.Postman
  com.github.d4nj1.tlpui
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  com.valvesoftware.Steam
  com.valvesoftware.Steam.CompatibilityTool.Proton
  com.visualstudio.code
  io.github.realmazharhussain.GdmSettings
  md.obsidian.Obsidian
  org.freedesktop.Platform.VulkanLayer.gamescope
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.gtk.Gtk3theme.adw-gtk3-dark
  org.libreoffice.LibreOffice
  org.signal.Signal
  runtime/org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
  us.zoom.Zoom
)

flatpak install --noninteractive ${flatpak_apps[@]}
