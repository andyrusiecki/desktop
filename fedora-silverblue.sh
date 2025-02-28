#!/bin/bash

# ensure directories are created
mkdir -p ~/.config
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/fonts

echo "Adding rpm-ostree layers..."

# upgrade base image
rpm-ostree upgrade

# add other repos
sudo curl https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora -o /etc/yum.repos.d/starship.repo
sudo curl https://pkgs.tailscale.com/stable/fedora/tailscale.repo -o /etc/yum.repos.d/tailscale.repo

# add layers
rpm-ostree update \
  --apply-live \
  --assumeyes \
  --uninstall firefox \
  --uninstall firefox-langpacks \
  --uninstall toolbox \
  --install adw-gtk3-theme \
  --install distrobox \
  --install neovim \
  --install starship \
  --install steam-devices \
  --install tailscale \
  --install zsh-autosuggestions \
  --install zsh-syntax-highlighting

echo "Enabling Tailscale..."

sudo systemctl enable tailscaled
tailscale set --operator=$USER

echo "Removing Fedora flatpak repo..."

# Replace fedora flatpak repo with flathub (https://www.reddit.com/r/Fedora/comments/z2kk88/fedora_silverblue_replace_the_fedora_flatpak_repo/)
if ! flatpak remotes | grep --quiet flathub; then
  sudo flatpak remote-modify --no-filter --enable flathub
fi

if flatpak info org.fedoraproject.MediaWriter &>/dev/null; then
  flatpak remove --noninteractive --assumeyes org.fedoraproject.MediaWriter
fi

if flatpak remotes | grep --quiet fedora; then
  flatpak install --noninteractive --assumeyes --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
  sudo flatpak remote-delete fedora
fi

echo "Installing flatpaks..."

flatpak_apps=(
  org.mozilla.firefox
  com.dec05eba.gpu_screen_recorder
  com.discordapp.Discord
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.nextcloud.desktopclient.nextcloud
  com.slack.Slack
  com.spotify.Client
  com.valvesoftware.Steam
  com.visualstudio.code
  dev.qwery.AddWater
  io.github.Foldex.AdwSteamGtk
  io.github.celluloid_player.Celluloid
  io.github.giantpinkrobots.flatsweep
  io.github.realmazharhussain.GdmSettings
  io.missioncenter.MissionCenter
  md.obsidian.Obsidian
  org.gnome.Boxes
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.libreoffice.LibreOffice
  org.signal.Signal
  us.zoom.Zoom
)

flatpak install --app --noninteractive ${flatpak_apps[@]}

# needed for firefox hw decode
flatpak install --runtime --noninteractive org.freedesktop.Platform.ffmpeg-full//23.08

echo "Adding starship terminal prompt and default zsh settings..."

##### Start of ~/.zshrc #####
cat << EOF > ~/.zshrc
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/$USER/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# env
export PATH="\$PATH:\$HOME/go/bin:\$HOME/.local/bin"

if command -v nvim 2>&1 /dev/null; then
  export EDITOR="\$(which nvim)"
fi

# plugins
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# completions
if command -v kubectl 2>&1 >/dev/null; then
  source <(kubectl completion zsh)
fi

if command -v tailscale 2>&1 >/dev/null; then
  source <(tailscale completion zsh)
fi

# starship
if command -v starship 2>&1 >/dev/null; then
  eval "\$(starship init zsh)"
fi

EOF
##### End of ~/.zshrc #####

##### Start of ~/.config/starship.toml #####
echo << EOF > ~/.config/starship.toml
format = "\$os\${custom.container} \$all"

[aws]
disabled = true
symbol = "  "

[buf]
symbol = " "

[c]
symbol = " "

[conda]
symbol = " "

[container]
disabled = true

[custom.container]
disabled = false
description = "The current container"
command = "echo -n \$(. /run/.containerenv; echo \$name)"
when = "test -f /run/.containerenv"
shell = "/bin/bash"
style = "white"
format = "[\\\\[\$output\\\\]](\$style)"

[crystal]
symbol = " "

[dart]
symbol = " "

[directory]
read_only = " 󰌾"

[docker_context]
disabled = true
symbol = " "

[elixir]
symbol = " "

[elm]
symbol = " "

[fennel]
symbol = " "

[fossil_branch]
symbol = " "

[git_branch]
symbol = " "

[git_commit]
#tag_symbol = ", "
tag_symbol = ",  "
only_detached = false
tag_disabled = false

[git_status]
ahead = "\${count}"
diverged = "\${ahead_count}\${behind_count}"
behind = "\${count}"

[golang]
symbol = " "

[guix_shell]
symbol = " "

[haskell]
symbol = " "

[haxe]
symbol = " "

[hg_branch]
symbol = " "

[hostname]
ssh_symbol = " "

[java]
symbol = " "

[julia]
symbol = " "

[kotlin]
symbol = " "

[lua]
symbol = " "

[memory_usage]
symbol = "󰍛 "

[meson]
symbol = "󰔷 "

[nim]
symbol = "󰆥 "

[nix_shell]
symbol = " "

[nodejs]
symbol = " "

[ocaml]
symbol = " "

[os]
disabled = false

[os.symbols]
Alpaquita = " "
Alpine = " "
AlmaLinux = " "
Amazon = " "
Android = " "
Arch = " "
Artix = " "
CentOS = " "
Debian = " "
DragonFly = " "
Emscripten = " "
EndeavourOS = " "
Fedora = " "
FreeBSD = " "
Garuda = "󰛓 "
Gentoo = " "
HardenedBSD = "󰞌 "
Illumos = "󰈸 "
Kali = " "
Linux = " "
Mabox = " "
Macos = " "
Manjaro = " "
Mariner = " "
MidnightBSD = " "
Mint = " "
NetBSD = " "
NixOS = " "
OpenBSD = "󰈺 "
openSUSE = " "
OracleLinux = "󰌷 "
Pop = " "
Raspbian = " "
Redhat = " "
RedHatEnterprise = " "
RockyLinux = " "
Redox = "󰀘 "
Solus = "󰠳 "
SUSE = " "
Ubuntu = " "
Unknown = " "
Void = " "
Windows = "󰍲 "

[package]
symbol = "󰏗 "

[perl]
symbol = " "

[php]
symbol = " "

[pijul_channel]
symbol = " "

[python]
symbol = " "

[rlang]
symbol = "󰟔 "

[ruby]
symbol = " "

[rust]
symbol = "󱘗 "

[shell]
disabled = false
bash_indicator = "bash"
fish_indicator = "fish"

[scala]
symbol = " "

[swift]
symbol = " "

[zig]
symbol = " "

[gradle]
symbol = " "

EOF
##### End of ~/.config/starship.toml #####

echo "Adding configs for containers..."

##### Start of ~/.config/containers/containers.conf #####
cat << EOF > ~/.config/containers/containers.conf
[containers]
label = false

[engine]
compose_providers = [ "podman-compose" ]
compose_warning_logs = false

EOF
##### End of ~/.config/containers/containers.conf #####

##### Start of ~/.config/containers/registries.conf #####
cat << EOF > ~/.config/containers/registries.conf
unqualified-search-registries = ["docker.io"]

EOF
##### End of ~/.config/containers/registries.conf #####
systemctl --user enable --now podman.socket

# adding scripts for container development
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/podman-host -o ~/.local/bin/podman-host
chmod +x ~/.local/bin/podman-host

curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/extras/vscode-distrobox -o ~/.local/bin/vscode-distrobox
chmod +x ~/.local/bin/vscode-distrobox

echo "Adding Nerd fonts..."

# nerd fonts
fonts=(
  FiraMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
  Ubuntu
  UbuntuMono
)

tmp_dir=$(mktemp -d)

for font in ${fonts[@]}
do
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $tmp_dir/$font.zip
  unzip $tmp_dir/$font.zip -d ~/.local/share/fonts/nerd-$font/
done

rm -rf $tmp_dir

echo "Updating Gnome settings..."

# general gnome settings
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type "nothing"

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'com.discordapp.Discord.desktop', 'com.valvesoftware.Steam.desktop', 'com.slack.Slack.desktop', 'md.obsidian.Obsidian.desktop', 'com.visualstudio.code.desktop', 'com.github.marhkb.Pods.desktop', 'org.gnome.Ptyxis.desktop']"

gsettings set org.gnome.shell.weather automatic-location true

echo "Adding Gnome Extensions..."

# extensions
extensions=(
  app-hider@lynith.dev
  AlphabeticalAppGrid@stuarthayhurst
  appindicatorsupport@rgcjonas.gmail.com
  caffeine@patapon.info
  just-perfection-desktop@just-perfection
  mediacontrols@cliffniff.github.com
  nightthemeswitcher@romainvigier.fr
  pip-on-top@rafostar.github.com
  #system-monitor@gnome-shell-extensions.gcampax.github.com
  tailscale@joaophi.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
)

shell_version=$(gnome-shell --version | cut -d' ' -f3)

for uuid in ${extensions[@]}
do
  if gnome-extensions list | grep --quiet $uuid; then
    break
  fi

  busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s $uuid
done

echo "Updating Gnome Extension settings..."

# extension settings
schemadir="~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.caffeine nightlight-control 'always'

schemadir="~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.just-perfection notification-banner-position 2

schemadir="~/.local/share/gnome-shell/extensions/mediacontrols@cliffniff.github.com/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols elements-order "['ICON', 'CONTROLS', 'LABEL']"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols extension-index 1
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols extension-position 'Left'
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols labels-order "['TITLE', '-', 'ARTIST']"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-backward true
gsettings --schemadir $schemadir set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-forward true

schemadir="~/.local/share/gnome-shell/extensions/nightthemeswitcher@romainvigier.fr/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.nightthemeswitcher.time manual-schedule true
gsettings --schemadir $schemadir set org.gnome.shell.extensions.nightthemeswitcher.time sunrise 6.0
gsettings --schemadir $schemadir set org.gnome.shell.extensions.nightthemeswitcher.time sunset 18.0

schemadir="~/.local/share/gnome-shell/extensions/pip-on-top@rafostar.github.com/schemas"
gsettings --schemadir $schemadir set org.gnome.shell.extensions.pip-on-top stick true

echo "\nSetup complete! Please restart your computer to apply all changes."
