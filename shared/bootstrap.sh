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

export -f taskLog
export -f taskItem
export -f dnfInstall
