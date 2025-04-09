#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Power"
taskItem "installing packages"
pacmanInstall tuned-ppd

taskItem "enabling power profiles service"
sudo systemctl enable --now tuned-ppd
