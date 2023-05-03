#!/bin/bash

num_updates=$(flatpak remote-ls --updates | wc -l)
alt=""
text=""

if [ $num_updates -gt 0 ]; then
    alt="updates"
    text="$num_updates"
fi

echo "{\"alt\":\"$alt\",\"text\":\"$text\"}"
