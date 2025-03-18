#!/bin/bash

set -e

source ../shared/bootstrap.sh

./actions/repositories.sh
./actions/packages.sh
./actions/video-support.sh
./actions/tailscale.sh
./actions/flatpak.sh
./actions/terminal.sh
./actions/development.sh
# TODO: fonts.sh
# TODO: gnome.sh
# TODO: snapshots.sh

echo "Adding Nerd fonts..."

# nerd fonts
fonts=(
  BitstreamVeraSansMono
  CascadiaCode
  CascadiaMono
  DejaVuSansMono
  FiraCode
  FiraMono
  Hack
  Iosevka
  IosevkaTerm
  JetBrainsMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
  Ubuntu
  UbuntuMono
)

tmp_dir=$(mktemp -d)
base_dir="/usr/share/fonts"

for font in ${fonts[@]}
do
  fontname="nerd-$(echo "$font" | sed 's/[A-Z]/-\l&/g' | sed 's/^-//')"
  fontdir="$base_dir/$fontname"

  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $tmp_dir/$font.zip

  if [ -d "$fontdir" ]; then
    sudo rm $fontdir
  fi

  sudo unzip $tmp_dir/$font.zip -d $fontdir/
done

rm -rf $tmp_dir

echo "Updating Gnome settings..."

# general gnome settings
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'discord.desktop', 'steam.desktop', 'com.slack.Slack.desktop', 'md.obsidian.Obsidian.desktop', 'code.desktop', 'com.github.marhkb.Pods.desktop', 'org.gnome.Ptyxis.desktop']"

gsettings set org.gnome.shell.weather automatic-location true

echo "Adding Gnome Extensions..."

# extensions
extensions=(
  app-hider@lynith.dev
  AlphabeticalAppGrid@stuarthayhurst
  appindicatorsupport@rgcjonas.gmail.com
  caffeine@patapon.info
  just-perfection-desktop@just-perfection
  mediacontrols@cliffniff.github.com
  nightthemeswitcher@romainvigier.fr
  pip-on-top@rafostar.github.com
  #system-monitor@gnome-shell-extensions.gcampax.github.com
  tailscale@joaophi.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
)

shell_version=$(gnome-shell --version | cut -d' ' -f3)

for uuid in ${extensions[@]}
do
  if gnome-extensions list | grep --quiet $uuid; then
    break
  fi

  busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s $uuid
done

echo "Updating Gnome Extension settings..."

# extension settings
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

echo "\nSetup complete! Please restart your computer to apply all changes."
