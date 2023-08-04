# remove fish greeting
set -g fish_greeting

# pywal
if test -e ~/.cache/wal/sequences
  cat ~/.cache/wal/sequences
end

# Starship
starship init fish | source
