#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Fonts"

taskItem "installing nerd fonts"
fonts=(
  BitstreamVeraSansMono
  CascadiaCode
  CascadiaMono
  DejaVuSansMono
  FiraCode
  FiraMono
  Hack
  Iosevka
  IosevkaTerm
  JetBrainsMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
  Ubuntu
  UbuntuMono
)

tmp_dir=$(mktemp -d)
base_dir="~/.local/share/fonts"

for font in ${fonts[@]}
do
  fontname="nerd-$(echo "$font" | sed 's/[A-Z]/-\l&/g' | sed 's/^-//')"
  fontdir="$base_dir/$fontname"

  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $tmp_dir/$font.zip

  if [ -d "$fontdir" ]; then
    rm $fontdir
  fi

  unzip $tmp_dir/$font.zip -d $fontdir/
done

rm -rf $tmp_dir

taskItem "clearing font cache"
fc-cache -r
