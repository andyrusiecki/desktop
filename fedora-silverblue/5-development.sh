#!/bin/bash

root=$(dirname $(realpath $0))

mkdir -p ~/.config
cp -r $root/dotfiles/dot_config/containers ~/.config/
cp -r $root/dotfiles/dot_docker ~/.docker

systemctl --user enable --now podman.socket
