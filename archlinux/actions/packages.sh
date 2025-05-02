#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Packages"
taskItem "updating pacman config"

# enabling multilib repo
sudo sed -i '/\[multilib\]/,+1 s/#//' /etc/pacman.conf

# misc options
sudo sed -i '/ParallelDownloads/s/^#//g' /etc/pacman.conf
sudo sed -i '/Color/s/^#//g' /etc/pacman.conf
sudo sed -i '/VerbosePkgLists/s/^#//g' /etc/pacman.conf

taskItem "installing paru AUR helper"
tmp_dir=$(mktemp -d)
git clone https://aur.archlinux.org/paru-bin.git $tmp_dir/paru
(cd $tmp_dir/paru && makepkg --noconfirm --needed -si)
rm -rf $tmp_dir

taskItem "updating paru config"
sudo sed -i '/NewsOnUpgrade/s/^#//g' /etc/paru.conf

taskItem "updating archlinux keyring"
sudo pacman-key --populate archlinux

taskItem "installing new packages"
pacmanInstall \
  adw-gtk-theme \
  celluloid \
  cups \
  discord \
  downgrade \
  file-roller \
  firefox \
  fprintd \
  gnome-boxes \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-caffeine \
  gnome-tweaks \
  google-chrome \
  iio-sensor-proxy \
  libreoffice-fresh \
  man-db \
  mangohud \
  mission-center \
  nautilus-python \
  nextcloud-client \
  obsidian \
  pacman-contrib \
  pika-backup \
  reflector \
  signal-desktop \
  steam

taskItem "enabling pacman cache cleaning timer"
sudo systemctl enable paccache.timer

taskItem "adding mirrorlist config"
sudo echo -e "--latest 10\n--sort rate\n--protocol https\n--save /etc/pacman.d/mirrorlist\n" > /etc/xdg/reflector/reflector.conf

taskItem "enabling mirrorlist refresh timer"
sudo systemctl enable reflector.timer

taskItem "enabling basic services"
sudo systemctl enable --now cups.service
sudo systemctl enable --now fprintd.service
sudo systemctl enable --now bluetooth.service
