#!/bin/bash

set -euo pipefail

basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Fonts"

nerd_fonts=(
  AdwaitaMono
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

ms_fonts=(
  andale32
  arial32
  arialb32
  comic32
  courie32
  georgi32
  impact32
  times32
  trebuc32
  verdan32
  webdin32
)

tmp_dir=$(mktemp -d)
base_dir="$HOME/.local/share/fonts"

mkdir -p $base_dir

taskItem "installing nerd fonts"
for font in ${nerd_fonts[@]}
do
  fontname="nerd-$(echo "$font" | sed 's/[A-Z]/-\l&/g' | sed 's/^-//')"
  fontdir="$base_dir/$fontname"

  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz --output $tmp_dir/$font.tar.xz &> /dev/null

  if [ -d "$fontdir" ]; then
    rm -r $fontdir
  fi

  mkdir -p $fontdir
  tar -xf $tmp_dir/$font.tar.xz  -C $fontdir/

  echo "Added Nerd Font: $font"
done

taskItem "installing ms fonts"
for font in ${ms_fonts[@]}
do
  fontdir="$base_dir/ms-$font"

  curl -L http://downloads.sourceforge.net/corefonts/$font.exe --output $tmp_dir/$font.exe &> /dev/null

  if [ -d "$fontdir" ]; then
    rm -r $fontdir
  fi

  mkdir -p $fontdir
  cabextract -d $fontdir/ $tmp_dir/$font.exe &>/dev/null

  echo "Added MS Font: $font"
done

rm -rf $tmp_dir

taskItem "clearing font cache"
fc-cache -r
