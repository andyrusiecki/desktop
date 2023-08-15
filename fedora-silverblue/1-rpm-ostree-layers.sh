#!/bin/bash

root=$(dirname $(realpath $0))

# upgrade base image
rpm-ostree upgrade

# add starship repo
sudo cp $root/dotfiles/etc/yum.repos.d/* /etc/yum.repos.d/

# add layers
rpm-ostree install --assumeyes fish starship tlp distrobox syncthing
