#!/bin/bash

# Terminate already running dunst instances
killall -q dunst

# source wal colors
source ~/.cache/wal/colors.sh

DUNST_FILE=~/.config/dunst/dunstrc

# update dunst based on pywal colors.
sed -i '/background = /s/.*/background = "'$color0'"/' $DUNST_FILE
sed -i '/foreground = /s/.*/foreground = "'$color7'"/' $DUNST_FILE
sed -i '/frame_color = /s/.*/frame_color = "'$color8'"/' $DUNST_FILE

# Launch Dunst
dunst --config ~/.config/dunst/dunstrc 2>&1 | tee -a /tmp/dunst.log & disown

# vim:ft=bash:nowrap
