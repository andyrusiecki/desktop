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
  docker \
  docker-buildx \
  docker-compose \
  docker-credential-secretservice-bin \
  git \
  go \
  jq \
  kubectl \
  k9s \
  lazydocker-bin \
  make \
  visual-studio-code-bin

taskItem "add user to docker group"
sudo usermod -aG docker $USER
newgrp docker

taskItem "add docker config"
mkdir -p ~/.docker
echo -e "{\n  \"credsStore\": \"secretservice\"\n}\n" > ~/.docker/config.json

taskItem "enable docker socket"
sudo systemctl enable --now docker.socket
