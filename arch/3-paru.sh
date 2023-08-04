#!/bin/bash

# Install paru (https://github.com/Morganamilo/paru)
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git $tmp_dir/paru
(cd $tmp_dir/paru && makepkg --noconfirm --needed -si)
rm -rf $tmp_dir

root=$(dirname $(realpath $0))
mkdir -p ~/.config
cp -r $root/dotfiles/dot_config/paru ~/.config/
