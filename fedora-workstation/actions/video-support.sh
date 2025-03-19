#!/bin/bash

set -e
basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Video Support"

taskItem "installing video codecs"
sudo dnf --assumeyes swap ffmpeg-free ffmpeg --allowerasing
sudo dnf --assumeyes update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

taskItem "enabling hardware media acceleration"
gpu="$(lspci | grep 'VGA')"

if echo "$gpu" | grep -i 'intel' > /dev/null; then
  sudo dnf --assumeyes install intel-media-driver
elif echo "$gpu" | grep -i 'nvidia' > /dev/null; then
  sudo dnf --assumeyes install libva-nvidia-driver.{i686,x86_64}
elif echo "$gpu" | grep -i 'amd' > /dev/null; then
  sudo dnf --assumeyes swap mesa-va-drivers mesa-va-drivers-freeworld
  sudo dnf --assumeyes swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
  sudo dnf --assumeyes swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
  sudo dnf --assumeyes swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
fi
