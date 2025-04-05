#!/bin/bash

taskLog() {
  echo ""
  echo "Task: $@..."
}

taskItem() {
  echo " - $@"
}

dnfInstall() {
  sudo dnf --assumeyes install $@
}

pacmanInstall() {
  paru -S --noconfirm --needed $@
}

export -f taskLog
export -f taskItem
export -f dnfInstall
