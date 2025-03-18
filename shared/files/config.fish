if status is-interactive
  # remove fish greeting
  set -g fish_greeting

  set -gx EDITOR "$(which nvim)"

  fish_add_path -g ~/.local/bin

  # completions
  if command -v kubectl > /dev/null
    kubectl completion fish | source
  end

  if command -v tailscale > /dev/null
    tailscale completion fish | source
  end

  # prompt
  if command -v starship > /dev/null
    starship init fish | source
  end
end
