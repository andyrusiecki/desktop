#!/bin/bash

root=$(dirname $(realpath $0))

packages=(
  # base
  adw-gtk3-theme
  #sushi
  tailscale

  # shell
  fish
  starship
  neovim

  # font dependencies
  curl
  cabextract
  xorg-x11-font-utils
  fontconfig

  # development
  awscli2
  distrobox
  docker-compose
  golang
  jq
  kubectl
  make
  moby-engine

  # Other applications
  celluloid
  code
  dconf-editor
  discord
  gnome-boxes
  gnome-tweaks
  google-chrome-stable
  libreoffice
  nextcloud-client
  steam
  mangohud
  gamescope
  timeshift # TODO: remove
)

flatpak_apps=(
  com.getpostman.Postman
  com.github.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  io.github.Foldex.AdwSteamGtk
  io.github.realmazharhussain.GdmSettings
  io.missioncenter.MissionCenter
  md.obsidian.Obsidian
  me.dusansimic.DynamicWallpaper
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.signal.Signal
  us.zoom.Zoom
)

systemd_services_root=(
  docker
  tailscaled
)

echo "Starting Fedora Workstation Post-Install Tasks..."

# 1. Update dnf conf
sudo bash -c 'echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf'

# 2. Enable RPM fusion
sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y update @core

# 3. Add COPR repos
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo cp $root/repos/* /etc/yum.repos.d/

# 4. update current packages
sudo dnf -y --refresh upgrade

# 5. Install Snapper and dnf plugin
sudo dnf -y install snapper python3-dnf-plugins-extras-snapper
sudo snapper --config=root create-config /
sudo snapper -c root set-config ALLOW_USERS=$USER SYNC_ACL=yes

# 6. Install Multimedia codecs
# - install full ffmpeg
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
sudo dnf -y update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf -y update @sound-and-video

# 7. Hardware acceleration
# - Intel
# sudo dnf -y install intel-media-driver

# - AMD
sudo dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# - NVIDIA
# sudo dnf -y install libva-nvidia-driver

# 8. Install packages
sudo dnf -y install ${packages[@]}

# 9. Install flatpak apps
flatpak install --noninteractive ${flatpak_apps[@]}

flatpak override --user com.slack.Slack --socket=wayland
flatpak override --user com.spotify.Client --socket=wayland
flatpak override --user md.obsidian.Obsidian --socket=wayland

# 12. Add fonts
# - nerd fonts
nerd_fonts=(
  FireCode
  FireMono
  JetBrainsMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
  Ubuntu
  UbuntuMono
)

nerd_tmp=$(mktemp -d)
for font in ${nerd_fonts[@]}
do
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $nerd_tmp/$font.zip
  font_dir=$(echo $font | sed 's/\([A-Z]\)/-\L\1/g;s/^-//')
  sudo unzip $nerd_tmp/$font.zip -d /usr/share/fonts/nerd-$font/
done

rm -rf $nerd_tmp

sudo fc-cache -f /usr/share/fonts

# - ms fonts
sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# 13. Post install dev tasks
sudo usermod -s $(command -v fish) $USER

# docker user
sudo groupadd docker
sudo usermod -aG docker $USER

# aws ecr helper
go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest

# 14. Gnome settings and extensions
extensions=(
  user-theme@gnome-shell-extensions.gcampax.github.com
  pip-on-top@rafostar.github.com
  nightthemeswitcher@romainvigier.fr
  mediacontrols@cliffniff.github.com
  just-perfection-desktop@just-perfection
  caffeine@patapon.info
  appindicatorsupport@rgcjonas.gmail.com
  system-monitor@gnome-shell-extensions.gcampax.github.com
  tailscale@joaophi.github.com
)

for uuid in ${extensions[@]}
do
  if gnome-extensions list | grep --quiet $uuid; then
    break
  fi

  busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s $uuid

  gnome-extensions enable $uuid
done

# gnome dconf settings
gsettings set org.gnome.desktop.datetime automatic-timezone true

gsettings set org.gnome.desktop.interface clock-format "12h"
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface font-hinting "slight"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

# fractional scaling
# gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# variable refresh rate
gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.system.location enabled true

# gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'com.valvesoftware.Steam.desktop', 'com.slack.Slack.desktop', 'net.cozic.joplin_desktop.desktop', 'com.visualstudio.code.desktop', 'org.gnome.Terminal.desktop']"

# extension settings
# just perfection
# gsettings set org.gnome.shell.extensions.just-perfection notification-banner-position 2
# gsettings set org.gnome.shell.extensions.just-perfection startup-status 0

# # media controls
# gsettings set org.gnome.shell.extensions.mediacontrols extension-index 1
# gsettings set org.gnome.shell.extensions.mediacontrols extension-position 'Left'
# gsettings set org.gnome.shell.extensions.mediacontrols label-width 300
# gsettings set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-backward false
# gsettings set org.gnome.shell.extensions.mediacontrols show-control-icons-seek-forward false

# # pip on top
# gsettings set org.gnome.shell.extensions.pip-on-top stick true

# 13. Enable systemd services
for i in ${systemd_services_root[@]}
do
	sudo systemctl enable $i
done

# Done
echo ""
echo  "Fedora Workstation Post-Install Tasks Complete!"
echo "Please run \"systemctl reboot\" to complete post install tasks."
