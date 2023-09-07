#!/bin/bash

status="$(playerctl status)"
prefix=""

if [ "$status" = "Paused" ]; then
  prefix=""
fi

playerctl metadata --format "{\"alt\": \"{{ playerName }}\", \"text\": \"$prefix {{ artist }} - {{ title }}\"}"
