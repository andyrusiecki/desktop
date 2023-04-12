#!/bin/bash

flatpak_cmd="flatpak run --branch=stable --arch=x86_64 --command=code --file-forwarding com.visualstudio.code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --reuse-window"

if [ "$(command -v flatpak-spawn)" != "" ]; then
  if [[ -d /run/containerenv ]]; then
    container_name="$(. /run/.containerenv && echo "$name")"
    container_name_encoded=$(echo -n "$container_name" | od -t x1 -A none -v | tr -d ' \n')

    flatpak_cmd+="--remote attached-container+\"$container_name_encoded\""
  fi

  exec flatpak-spawn --host $flatpak_cmd $@
elif [ "$(command -v flatpak)" != "" ]; then
  exec $flatpak_cmd $@
else
  echo "unable to launch com.visualstudio.code flatpak!"
fi
