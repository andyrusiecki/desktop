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
  nodejs \
  npm \
  visual-studio-code-bin

taskItem "add user to docker group"
sudo usermod -aG docker $USER
newgrp docker

taskItem "add docker config"
mkdir -p ~/.docker
echo -e "{\n  \"credsStore\": \"secretservice\"\n}\n" > ~/.docker/config.json

taskItem "allow container lower port binding"
echo "net.ipv4.ip_unprivileged_port_start = 80" | sudo tee /etc/sysctl.d/99-containers.conf > /dev/null

taskItem "enable docker socket"
sudo systemctl enable --now docker.socket
