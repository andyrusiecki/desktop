#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Packages"
taskItem "installing AUR helper"
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git $tmp_dir/paru
(cd $tmp_dir/paru && makepkg --noconfirm --needed -si)
rm -rf $tmp_dir
mkdir -p ~/.config/paru
install -Dm644 $basedir/../files/paru.conf ~/.config/paru/paru.conf

taskItem "updating archlinux keyring"
sudo pacman-key --populate archlinux

taskItem "installing new packages"
pacmanInstall \
  adw-gtk-theme \
  discord \
  downgrade \
  fprintd \
  gnome-tweaks \
  man-db \
  mangohud \
  pacman-contrib \
  reflector \
  steam

taskItem "enabling pacman cache cleaning timer"
sudo systemctl enable paccache.timer

taskItem "adding mirrorlist config"
sudo install -Dm644 $basedir/../files/reflector.conf /etc/xdg/reflector/reflector.conf

taskItem "enabling mirrorlist refresh timer"
sudo systemctl enable reflector.timer
