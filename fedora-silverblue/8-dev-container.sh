#!/bin/bash

root=$(dirname $(realpath $0))

podman build -t dev-toolbox -f $root/dotfiles/misc/Containerfile
toolbox create -i dev-toolbox dev

# expose VS Code desktop file to host
toolbox run -c dev -- bash -c '\
  mkdir -p ~/.local/share/applications && \
  cp /usr/share/applications/code.desktop ~/.local/share/applications/ && \
  mkdir -p ~/.local/share/icons && \
  cp /usr/share/pixmaps/com.visualstudio.code.png ~/.local/share/icons/'

sed -i 's/Exec=/Exec=toolbox run --container dev -- /g' ~/.local/share/applications/code.desktop
