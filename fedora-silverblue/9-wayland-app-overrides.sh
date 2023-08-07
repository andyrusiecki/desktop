#!/bin/bash

mkdir -p ~/.local/share/applications/

# Enable wayland
# vs code
sed -i 's/@@ %F @@/--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland @@ %F @@/g' ~/.local/share/applications/code.desktop

# slack
sed 's/@@u %U @@/--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer --ozone-platform=wayland @@u %U @@/g' /var/lib/flatpak/exports/share/applications/com.slack.Slack.desktop > ~/.local/share/applications/com.slack.Slack.desktop

# postman
sed 's/@@u %U @@/--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland @@u %U @@/g' /var/lib/flatpak/exports/share/applications/com.getpostman.Postman.desktop > ~/.local/share/applications/com.getpostman.Postman.desktop
