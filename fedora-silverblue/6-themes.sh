#!/bin/bash

mkdir -p ~/.local/share/themes/

tmp_dir=$(mktemp -d)
curl -L https://github.com/lassekongo83/adw-gtk3/releases/download/v4.8/adw-gtk3v4-8.tar.xz --output $tmp_dir/adw-gtk3v4-8.tar.xz
tar -xf $tmp_dir/adw-gtk3v4-8.tar.xz -C ~/.local/share/themes/
rm -rf $tmp_dir
