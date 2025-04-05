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

taskItem "add options to presets"
sudo sed -i '/quiet/! s/$/& quiet/' /etc/kernel/cmdline
sudo sed -i '/splash/! s/$/& splash/' /etc/kernel/cmdline

taskItem "build unified kernel image"
sudo mkinitcpio -P
