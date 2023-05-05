#!/bin/bash

# Replace fedora flatpak repo with flathub (https://www.reddit.com/r/Fedora/comments/z2kk88/fedora_silverblue_replace_the_fedora_flatpak_repo/)
sudo flatpak remote-modify --no-filter --enable flathub
flatpak remove --noninteractive --assumeyes org.fedoraproject.MediaWriter
flatpak install --noninteractive --assumeyes --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
sudo flatpak remote-delete fedora
