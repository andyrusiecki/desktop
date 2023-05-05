#!/bin/bash

root=$(dirname $(realpath $0))

exec $root/1-rpm-ostree-layers.sh
exec $root/2-replace-fedora-flatpak.sh
exec $root/3-install-flatpaks.sh
exec $root/4-shell.sh
exec $root/5-development.sh
exec $root/6-themes.sh
exec $root/7-fonts.sh
exec $root/8-dev-container.sh
exec $root/9-wayland-app-overrides.sh
exec $root/10-gnome.sh
exec $root/11-device-framework.sh

echo -e "\nFull Install Complete!!!"
echo -e "Please Reboot and run the after-reboot.sh script.\n"
