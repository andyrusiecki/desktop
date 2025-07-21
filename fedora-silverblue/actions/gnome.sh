#!/bin/bash

set -euo pipefail

basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "GNOME"

taskItem "updating GNOME settings"

# general gnome settings
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'com.discordapp.Discord.desktop', 'com.valvesoftware.Steam.desktop', 'com.slack.Slack.desktop', 'md.obsidian.Obsidian.desktop', 'com.visualstudio.code.desktop', 'com.github.marhkb.Pods.desktop', 'org.gnome.Ptyxis.desktop']"

gsettings set org.gnome.shell.weather automatic-location true
