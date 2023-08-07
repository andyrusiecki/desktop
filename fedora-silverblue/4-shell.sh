#!/bin/bash

root=$(dirname $(realpath $0))

mkdir -p ~/.config
cp -r $root/dotfiles/dot_config/fish ~/.config/
cp -r $root/dotfiles/dot_config/starship.toml ~/.config/
