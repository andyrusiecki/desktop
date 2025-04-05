#!/bin/bash

set -e
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

taskItem "installing GNOME extensions"

extensions=(
  app-hider@lynith.dev
  AlphabeticalAppGrid@stuarthayhurst
  appindicatorsupport@rgcjonas.gmail.com
  caffeine@patapon.info
  just-perfection-desktop@just-perfection
  mediacontrols@cliffniff.github.com
  nightthemeswitcher@romainvigier.fr
  pip-on-top@rafostar.github.com
  system-monitor@gnome-shell-extensions.gcampax.github.com
  tailscale@joaophi.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
)

for uuid in ${extensions[@]}
do
  if gnome-extensions list | grep --quiet $uuid; then
    continue
  fi

  busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s $uuid
done

taskItem "updating GNOME extension settings"

schemadir="~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.caffeine nightlight-control 'always'

schemadir="~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.just-perfection notification-banner-position 2

schemadir="~/.local/share/gnome-shell/extensions/mediacontrols@cliffniff.github.com/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols elements-order "['ICON', 'CONTROLS', 'LABEL']"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols extension-index 1
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols extension-position 'Left'
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols labels-order "['TITLE', '-', 'ARTIST']"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-backward true
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-forward true

schemadir="~/.local/share/gnome-shell/extensions/nightthemeswitcher@romainvigier.fr/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.nightthemeswitcher.time manual-schedule true
gsettings --schemadir $schemadir set org.gnome.shell.extensions.nightthemeswitcher.time sunrise 6.0
gsettings --schemadir $schemadir set org.gnome.shell.extensions.nightthemeswitcher.time sunset 18.0

schemadir="~/.local/share/gnome-shell/extensions/pip-on-top@rafostar.github.com/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.pip-on-top stick true
