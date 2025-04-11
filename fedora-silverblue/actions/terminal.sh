#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Terminal"

taskItem "installing packages"
ostreeInstall --apply-live \
  btop \
  fastfetch \
  fish \
  neovim \
  ranger \
  starship

taskItem "changing default shell to 'fish'"
sudo chsh -s /usr/bin/fish $USER

taskItem "creating fish configuration"
mkdir -p ~/.config/fish
install -Dm644 $basedir/../../shared/files/config.fish ~/.config/fish/config.fish

taskItem "creating starship configuration"
install -Dm644 $basedir/../../shared/files/starship.toml ~/.config/starship.toml
