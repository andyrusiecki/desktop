#!/bin/bash

taskLog "Printers"

taskItem "installing cups and cups-browsed"
pacmanInstall cups cups-browsed

if ! grep -q '^CreateRemotePrinters Yes' /etc/cups/cups-browsed.conf; then
  echo 'CreateRemotePrinters Yes' | sudo tee -a /etc/cups/cups-browsed.conf
fi

sudo systemctl enable --now cups.service
sudo systemctl enable --now cups-browsed.service
