#!/bin/bash

version="3.0.2"
fonts=(
  FiraMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
)

mkdir -p ~/.local/share/fonts/
tmp_dir=$(mktemp -d)

for font in ${fonts[@]}
do
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v$version/$font.zip --output $tmp_dir/$font.zip
  unzip $tmp_dir/$font.zip -d ~/.local/share/fonts/$font/
done

rm -rf $tmp_dir
