#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))

$basedir/actions/base.sh
$basedir/actions/snapshots.sh
$basedir/actions/tailscale.sh
$basedir/actions/apps.sh
$basedir/actions/gaming.sh
$basedir/actions/terminal.sh
$basedir/actions/development.sh
$basedir/actions/fonts.sh
$basedir/actions/gnome.sh
$basedir/actions/power.sh
$basedir/actions/network.sh
$basedir/actions/plymouth.sh

echo "\nSetup complete! Please restart your computer to apply all changes."

# Manual Tasks

# - setup secure boot with https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Assisted_process_with_sbctl
