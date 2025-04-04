#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Development"

taskItem "installing packages"
pacmanInstall \
  aws-cli-v2 \
  distrobox \
  git \
  go \
  jq \
  kubectl \
  k9s \
  make \
  podman-compose \
  podman-docker \
  visual-studio-code-bin

taskItem "creating podman configuration"
mkdir -p ~/.config/containers
install -Dm644 $basedir/../../shared/files/containers.conf ~/.config/containers/containers.conf

taskItem "enabling podman socket"
systemctl --user enable --now podman.socket

taskItem "adding local scripts for container development"
mkdir -p ~/.local/bin
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/podman-host -o ~/.local/bin/podman-host
chmod +x ~/.local/bin/podman-host

curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/vscode-distrobox -o ~/.local/bin/vscode-distrobox
chmod +x ~/.local/bin/vscode-distrobox
