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

taskItem "creating dev distrobox"
k8s_repo="[kubernetes]\
name=Kubernetes\
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/\
enabled=1\
gpgcheck=1\
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key\
"

distrobox create \
  --yes \
  --image registry.fedoraproject.org/fedora-toolbox:latest \
  --name dev \
  --pre-init-hooks "echo 'max_parallel_downloads=20' >> /etc/dnf/dnf.conf && \
  curl https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora -o /etc/yum.repos.d/starship.repo && \
  echo \"$k8s_repo\" > /etc/yum.repos.d/kubernetes.repo && \
  ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
  ln -s /usr/local/bin/podman /usr/local/bin/docker" \
  --additional-packages "awscli2 git golang jq make neovim podman-compose starship fish" \
  --init-hooks "ln -s /usr/bin/podman-compose /usr/local/bin/docker-compose"
