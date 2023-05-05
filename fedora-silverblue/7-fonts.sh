#!/bin/bash

mkdir -p ~/.local/share/fonts/

# Roboto Mono Nerd Font
tmp_dir=$(mktemp -d)
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/RobotoMono.zip --output $tmp_dir/RobotoMono.zip
unzip $tmp_dir/RobotoMono.zip -d ~/.local/share/fonts/RobotoMono/
rm -rf $tmp_dir
