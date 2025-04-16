#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Terminal"

taskItem "changing default shell to 'fish'"
sudo chsh -s /usr/bin/fish $USER

taskItem "creating fish configuration"
mkdir -p $HOME/.config/fish
install -Dm644 $basedir/../../shared/files/config.fish $HOME/.config/fish/config.fish

taskItem "creating starship configuration"
install -Dm644 $basedir/../../shared/files/starship.toml $HOME/.config/starship.toml
