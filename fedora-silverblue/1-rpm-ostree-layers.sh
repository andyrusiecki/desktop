#!/bin/bash

root=$(dirname $(realpath $0))

# upgrade base image
sudo rpm-ostree upgrade

# add starship and code repos
sudo cp $root/dotfiles/etc/yum.repos.d/* /etc/yum.repos.d/

# add layers
sudo rpm-ostree install --assumeyes fish starship tlp distrobox syncthing
