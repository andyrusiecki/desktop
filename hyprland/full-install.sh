#!/bin/bash

root=$(dirname $(realpath $0))

exec $root/1-setup-snapper.sh
exec $root/2-pacman.sh
exec $root/3-paru.sh
exec $root/4-base.sh
exec $root/5-audio.sh
exec $root/6-bluetooth.sh
exec $root/7-firewall.sh
exec $root/8-samba.sh
exec $root/9-printing.sh
exec $root/10-display-manager.sh
exec $root/11-shell.sh
exec $root/12-development.sh
exec $root/13-hyprland.sh
exec $root/14-apps.sh
exec $root/15-device-framework.sh
exec $root/16-snapshot.sh

echo -e "\nFull Install Complete!!!\n\n"
