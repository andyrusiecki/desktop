#!/bin/bash

# Setup snapper and add pacman hooks (https://www.reddit.com/r/Fedora/comments/n1ekg0/comment/gwfxvhc/?utm_source=reddit&utm_medium=web2x&context=3)

sudo pacman -S --noconfirm --needed snapper snap-pac
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /

sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable snapper-timeline.timer
