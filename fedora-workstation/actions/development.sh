#!/bin/bash

taskLog "Development"

taskItem "installing packages"
dnfInstall \
  awscli2 \
  code \
  distrobox \
  git \
  golang \
  jq \
  kubectl \
  make \
  podman-compose \
  podman-docker

taskItem "creating podman configuration"
mkdir -p ~/.config/containers
install -Dm644 ../shared/files/containers.conf ~/.config/containers/containers.conf

taskItem "enabling podman socket"
systemctl --user enable --now podman.socket

taskItem "adding local scripts for container development"
mkdir -p ~/.local/bin
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/podman-host -o ~/.local/bin/podman-host
chmod +x ~/.local/bin/podman-host

curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/vscode-distrobox -o ~/.local/bin/vscode-distrobox
chmod +x ~/.local/bin/vscode-distrobox
