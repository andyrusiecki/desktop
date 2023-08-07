# remove fish greeting
set -g fish_greeting

# adding local bin to path
fish_add_path -g ~/.local/bin

# pywal
if test -e ~/.cache/wal/sequences
  cat ~/.cache/wal/sequences
end

# Starship
starship init fish | source

