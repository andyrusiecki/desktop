#!/bin/sh

# echo "=== Arch + AUR ==="
# paru -Syu --noupgrademenu --removemake

# echo ""
# echo "=== flatpak ==="
flatpak update

# close
echo ""
read -p "Press Enter to Close"
