#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Fonts"

taskItem "installing fonts"
pacmanInstall \
  otf-firamono-nerd \
  ttf-bitstream-mono-nerd \
  ttr-cascadia-code-nerd \
  ttf-cascadia-mono-nerd \
  ttf-dejavu-nerd \
  ttf-firacode-nerd \
  ttf-hack-nerd \
  ttf-iosevka-nerd \
  ttf-iosevkaterm-nerd \
  ttf-jetbrains-mono-nerd \
  ttf-meslo-nerd \
  ttf-ms-fonts \
  ttf-noto-nerd \
  ttf-roboto-mono-nerd \
  ttf-space-mono-nerd \
  ttf-sourcecodepro-nerd \
  ttf-ubuntu-mono-nerd \
  ttf-ubuntu-nerd

taskItem "clearing font cache"
sudo fc-cache -r
