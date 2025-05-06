#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Gaming"

taskItem "installing packages"
pacmanInstall \
  gamemode \
  gamescope \
  lib32-gamemode \
  mangohud \
  steam

taskItem "installing flatpaks"
flatpak_apps=(
  com.dec05eba.gpu_screen_recorder
  com.heroicgameslauncher.hgl
  io.github.Foldex.AdwSteamGtk
  org.prismlauncher.PrismLauncher
)
flatpak install --app --noninteractive ${flatpak_apps[@]}

taskItem "add user to gamemode group"
sudo usermod -aG gamemode $USER
newgrp gamemode

taskItem "gamemode service?"
