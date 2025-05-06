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
  docker-desktop \
  docker-credential-pass \
  git \
  go \
  jq \
  kubectl \
  k9s \
  lazydocker-bin \
  make \
  pass \
  visual-studio-code-bin

taskItem "add user to docker group"
sudo usermod -aG docker $USER
newgrp docker

taskItem "add docker config"
mkdir -p ~/.docker
echo -e "{\n  \"credsStore\": \"pass\"\n}\n" > ~/.docker/config.json

taskItem "allow container lower port binding"
echo "net.ipv4.ip_unprivileged_port_start = 80" | sudo tee /etc/sysctl.d/99-containers.conf > /dev/null
