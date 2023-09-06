#!/bin/bash

volume_notify() {
  local is_mute=$(pamixer --get-mute)
  local value="$(pamixer --get-volume)"
  local msg="$value%"

  if [ $is_mute == "true" ]; then
    value="0"
    msg="muted"
  fi

  notify-send -e -h string:x-canonical-private-synchronous:volume \
    -h "int:value:$value" -t 2000 "Volume: ${msg}"
}

microphone_notify() {
  local is_mute=$(pamixer --default-source --get-mute)
  local value="$(pamixer --default-source --get-volume)"
  local msg="$value%"

  if [ $is_mute == "true" ]; then
    value="0"
    msg="muted"
  fi

  notify-send -e -h string:x-canonical-private-synchronous:microphone \
    -h "int:value:$value" -t 2000 "Microphone: ${msg}"
}

case $1 in
  get)
    echo "$(pamixer --get-volume)"
    ;;

  set)
    pamixer --set-volume $2
    volume_notify
    ;;

  increase)
    pamixer --increase $2
    volume_notify
    ;;

  decrease)
    pamixer --decrease $2
    volume_notify
    ;;

  mute)
    pamixer --mute
    volume_notify
    ;;

  unmute)
    pamixer --unmute
    volume_notify
    ;;

  toggle-mute)
    pamixer --toggle-mute
    volume_notify
    ;;

  microphone)
    case $2 in
      get)
        echo "$(pamixer --default-source --get-volume)"
        ;;

      set)
        pamixer --default-source --set-volume $2
        microphone_notify
        ;;

      increase)
        pamixer --default-source --increase $2
        microphone_notify
        ;;

      decrease)
        pamixer --default-source --decrease $2
        microphone_notify
        ;;

      mute)
        pamixer --default-source --mute
        microphone_notify
        ;;

      unmute)
        pamixer --default-source --unmute
        microphone_notify
        ;;

      toggle-mute)
        pamixer --default-source --toggle-mute
        microphone_notify
        ;;

      *)
        echo "microphone command $2 not recognized"
        ;;
    esac
    ;;

  *)
    echo "command $1 not recognized"
    ;;
esac
