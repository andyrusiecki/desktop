#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Development"

taskItem "creating podman configuration"
mkdir -p $HOME/.config/containers
install -Dm644 $basedir/../../shared/files/containers.conf $HOME/.config/containers/containers.conf

taskItem "enabling podman socket"
systemctl --user enable --now podman.socket

taskItem "adding local scripts for container development"
mkdir -p $HOME/.local/bin
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/podman-host -o $HOME/.local/bin/podman-host
chmod +x $HOME/.local/bin/podman-host

curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/vscode-distrobox -o $HOME/.local/bin/vscode-distrobox
chmod +x $HOME/.local/bin/vscode-distrobox
