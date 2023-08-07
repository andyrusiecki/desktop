#!/bin/bash

# Install extensions
extensions=(
  AlphabeticalAppGrid@stuarthayhurst
  appindicatorsupport@rgcjonas.gmail.com
  blur-my-shell@aunetx
  caffeine@patapon.info
  mediacontrols@cliffniff.github.com
  nightthemeswitcher@romainvigier.fr
  no-overview@fthx
  notification-banner-reloaded@marcinjakubowski.github.com
  pip-on-top@rafostar.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
  Vitals@CoreCoding.com
)

shell_version=$(gnome-shell --version | cut -d' ' -f3)

for uuid in ${extensions[@]}
do
  info_json=$(curl -sS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")
  download_url=$(echo $info_json | jq ".download_url" --raw-output)

  gnome-extensions install "https://extensions.gnome.org$download_url"
  gnome-extensions enable $uuid
done

# gnome dconf settings
gsettings set org.gnome.desktop.datetime automatic-timezone true

gsettings set org.gnome.desktop.interface clock-format "12h"
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface font-hinting "slight"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"
gsettings set org.gnome.desktop.interface color-scheme 'default'

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<SHIFT><SUPER>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<SHIFT><SUPER>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<SHIFT><SUPER>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<SHIFT><SUPER>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<SHIFT><SUPER>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<SHIFT><SUPER>6']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<SHIFT><SUPER>7']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 "['<SHIFT><SUPER>8']"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<SUPER>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<SUPER>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<SUPER>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<SUPER>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<SUPER>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<SUPER>6']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<SUPER>7']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<SUPER>8']"

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'com.valvesoftware.Steam.desktop', 'com.slack.Slack.desktop', 'md.obsidian.Obsidian.desktop', 'com.visualstudio.code.desktop', 'org.gnome.Terminal.desktop']"
