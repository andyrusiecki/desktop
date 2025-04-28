#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Development"

taskItem "installing packages"
dnfInstall \
  awscli2 \
  code \
  git \
  golang \
  jq \
  kubectl \
  make \
  podman-compose \
  podman-docker

taskItem "creating podman configuration"
mkdir -p ~/.config/containers
install -Dm644 $basedir/../../shared/files/containers.conf ~/.config/containers/containers.conf

taskItem "enabling podman socket"
systemctl --user enable --now podman.socket
