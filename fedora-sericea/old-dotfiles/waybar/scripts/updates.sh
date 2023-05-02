#!/bin/sh

#arch=$(checkupdates | wc -l)
#aur=$(checkupdates-aur | wc -l)
#dnf=$(dnf check-update -q | wc -l)
#flatpak=$(flatpak remote-ls --updates | wc -l)
#updates=$((arch + aur + flatpak))

updates=$(flatpak remote-ls --updates | wc -l)
if [ "$updates" -gt 0 ]; then
    echo " $updates"
fi
