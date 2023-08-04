#!/bin/bash

sudo pacman -S --noconfirm --needed fish starship

root=$(dirname $(realpath $0))
mkdir -p ~/.config
cp -r $root/dotfiles/dot_config/fish ~/.config/
cp -r $root/dotfiles/dot_config/starship.toml ~/.config/

# Change default shell to fish
sudo chsh -s $(command -v fish) $USER
