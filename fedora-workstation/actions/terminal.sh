#!/bin/bash

taskLog "Terminal"

taskItem "installing packages"
dnfInstall \
  btop \
  fastfetch \
  fish \
  neovim \
  ranger \
  starship

taskItem "changing default shell to 'fish'"
sudo chsh -s /usr/bin/fish $USER

taskItem "creating fish configuration"
mkdir -p ~/.local/bin
install -Dm644 ../shared/files/config.fish ~/.config/fish/config.fish

taskItem "creating starship configuration"
mkdir -p ~/.config
install -Dm644 ../shared/files/starship.toml ~/.config/starship.toml
