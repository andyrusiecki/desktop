#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Development"

taskItem "installing packages"
pacmanInstall \
  atac \
  aws-cli-bin \
  docker \
  docker-buildx \
  docker-compose \
  ducker \
  git \
  go \
  jq \
  kubectl \
  k9s \
  make \
  visual-studio-code-bin

taskItem "add user to docker group"
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

taskItem "enable docker socket"
sudo systemctl enable --now docker.socket
