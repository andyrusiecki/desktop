#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))

$basedir/actions/packages.sh
$basedir/actions/snapshots.sh
$basedir/actions/tailscale.sh
$basedir/actions/flatpak.sh
$basedir/actions/terminal.sh
$basedir/actions/development.sh
$basedir/actions/fonts.sh
$basedir/actions/gnome.sh
$basedir/actions/power.sh
$basedir/actions/firewall.sh
$basedir/actions/plymouth.sh

echo "\nSetup complete! Please restart your computer to apply all changes."

