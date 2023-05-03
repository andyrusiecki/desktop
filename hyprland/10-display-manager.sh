#!/bin/bash

paru -S --noconfirm --needed sddm-git

sudo systemctl enable sddm.service
