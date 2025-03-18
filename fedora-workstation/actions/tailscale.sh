#!/bin/bash

taskLog "Tailscale"

taskItem "installing tailscale"
dnfInstall tailscale

taskItem "enabling tailscale"
sudo systemctl enable tailscaled
tailscale set --operator=$USER
