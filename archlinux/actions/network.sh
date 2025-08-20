#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Network"
taskItem "installing apps"
pacmanInstall firewalld

taskItem "disabling MAC randomization during wifi scanning"
sudo cat << EOF > /etc/NetworkManager/conf.d/wifi_rand_mac.conf
[device-mac-randomization]
# Disable random MAC for wifi scanning
wifi.scan-rand-mac-address=no

[connection-mac-randomization]
# Randomize MAC for every ethernet connection
ethernet.cloned-mac-address=random
# Generate a random MAC for each Wi-Fi and associate the two permanently.
wifi.cloned-mac-address=stable
EOF

taskItem "enabling systemd services"
sudo systemctl enable --now systemd-resolved
sudo systemctl enable --now firewalld
