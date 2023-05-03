#!/bin/bash

paru -S --noconfirm --needed \
amazon-ecr-credential-helper \
aws-cli-v2 \
docker-compose \
go \
jq \
kubectl \
make \
podman \
podman-docker

root=$(dirname $(realpath $0))
mkdir ~/.config
cp -r $root/dotfiles/dot_config/containers ~/.config/
cp -r $root/dotfiles/dot_docker ~/.docker

sudo systemctl enable podman.socket
