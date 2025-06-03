#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Development"

taskItem "installing packages"
pacmanInstall \
  atac \
  aws-cli-bin \
  difftastic \
  git \
  go \
  jq \
  kubectl \
  k9s \
  lazydocker-bin \
  make \
  nodejs \
  npm \
  podman-compose \
  podman-docker \
  podman-tui \
  visual-studio-code-bin

taskItem "allow container lower port binding"
echo "net.ipv4.ip_unprivileged_port_start = 80" | sudo tee /etc/sysctl.d/99-containers.conf > /dev/null

task "add containers configurations"
mkdir -p ~/.config/containers
install -Dm644 $basedir/../../shared/files/containers.conf ~/.config/containers/containers.conf
install -Dm644 $basedir/../../shared/files/registries.conf ~/.config/containers/registries.conf

taskItem "enable podman socket"
systemctl --user enable --now podman.socket
