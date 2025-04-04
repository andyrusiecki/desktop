#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Firewall"
taskItem "installing apps"
pacmanInstall firewalld

taskItem "enabling firewall service"
sudo systemctl enable firewalld
