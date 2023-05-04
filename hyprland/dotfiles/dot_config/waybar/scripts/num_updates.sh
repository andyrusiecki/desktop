#!/bin/bash

#!/bin/sh

arch=$(checkupdates | wc -l)
aur=$(checkupdates-aur | wc -l)
flatpak=$(flatpak remote-ls --updates | wc -l)

num_updates=$((arch + aur + flatpak))
alt=""
text=""

if [ $num_updates -gt 0 ]; then
    alt="updates"
    text="$num_updates"
fi

echo "{\"alt\":\"$alt\",\"text\":\"$text\"}"
