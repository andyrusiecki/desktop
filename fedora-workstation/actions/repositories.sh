#!/bin/bash

taskLog "DNF Repositories"

taskItem "increasing max parallel downloads to 20"
if ! grep 'max_parallel_downloads=20' /etc/dnf/dnf.conf > /dev/null; then
  echo 'max_parallel_downloads=20' | sudo tee -a /etc/dnf/dnf.conf
fi

taskItem "updating existing packages"
sudo dnf --refresh --assumeyes update > /dev/null

taskItem "adding new packages repos"
sudo dnf --assumeyes install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo curl https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora -o /etc/yum.repos.d/starship.repo
sudo curl https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

sudo cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo cat << EOF > /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

