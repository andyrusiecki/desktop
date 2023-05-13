#!/bin/bash

apps=(
  firefox
  flatpak
  libreoffice-fresh
  spotify-launcher
  visual-studio-code-bin
)

flatpak_apps=(
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  # com.slack.Slack
  # com.spotify.Client
  com.usebottles.bottles
  # com.valvesoftware.Steam
  # com.valvesoftware.Steam.CompatibilityTool.Proton
  # com.valvesoftware.Steam.Utility.gamescope
  net.cozic.joplin_desktop
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  # org.libreoffice.LibreOffice
  # org.signal.Signal
  # us.zoom.Zoom
)

paru -S --noconfirm --needed ${apps[@]}
flatpak install --noninteractive ${flatpak_apps[@]}
