#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Plymouth"
taskItem "installing packages"
pacmanInstall plymouth

taskItem "add plymouth hook to mkinitcpio"
# add plymouth hook after "base udev"
sudo sed -i '/plymouth/! s/HOOKS=(base udev*/& plymouth/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

taskItem "add options to presets"
sudo sed -ir '/quiet/! s/default_options="(.*)"/default_options="\1 quiet"/' /etc/mkinitcpio.d/linux.preset
sudo sed -ir '/splash/! s/default_options="(.*)"/default_options="\1 splash"/' /etc/mkinitcpio.d/linux.preset

sudo sed -ir '/quiet/! s/default_options="(.*)"/default_options="\1 quiet"/' /etc/mkinitcpio.d/linux-lts.preset
sudo sed -ir '/splash/! s/default_options="(.*)"/default_options="\1 splash"/' /etc/mkinitcpio.d/linux-lts.preset

taskItem "TODO: secure boot signing"
