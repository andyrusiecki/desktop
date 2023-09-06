#!/bin/bash

brightness_notify() {
  local value=$(light)
  value=${value%%.*}

  notify-send -e -h string:x-canonical-private-synchronous:brightness \
    -h "int:value:$value" -t 2000 "Brightness: ${value}%"
}

case $1 in
  get)
    echo "$(light -G)"
    ;;

  set)
    light -S $2
    brightness_notify
    ;;

  increase)
    light -A $2
    brightness_notify
    ;;

  decrease)
    light -U $2
    brightness_notify
    ;;

  *)
    echo "command $1 not recognized"
    ;;
esac
