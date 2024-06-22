#!/bin/bash

root=$(dirname $(realpath $0))

packages=(
  # base
  adw-gtk3-theme
  tailscale

  # shell
  btop
  fastfetch
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
  golang
  jq
  kubectl
  make

  # snapshots
  snapper
  python3-dnf-plugins-extras-snapper

  # Other applications
  celluloid
  code
  dconf-editor
  discord
  gnome-console
  gnome-boxes
  gnome-tweaks
  google-chrome-stable
  heroic-games-launcher-bin
  libreoffice
  nextcloud-client
  steam
  mangohud
  gamescope
)

flatpak_apps=(
  com.getpostman.Postman
  com.github.marhkb.Pods
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
  tailscaled
)

echo "Starting Fedora Workstation Post-Install Tasks..."

# 1. Update dnf conf
sudo bash -c 'echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf'

# 2. Enable RPM fusion
sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y update @core

# 3. Add COPR repos
sudo cp $root/repos/* /etc/yum.repos.d/

# 4. update current packages
sudo dnf -y --refresh upgrade

# 5. Install packages
sudo dnf -y install ${packages[@]}

# 6. Snapper configs
sudo snapper --config=root create-config /
sudo snapper -c root set-config ALLOW_USERS=$USER SYNC_ACL=yes

# 7. Install Multimedia codecs
# - install full ffmpeg
sudo dnf -y swap ffmpeg-free ffmpeg --allowerasing
sudo dnf -y update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf -y update @sound-and-video

# 8. Hardware acceleration
gpu="$(lspci | grep 'VGA')"

if echo "$gpu" | grep -i 'intel' > /dev/null; then
  sudo dnf -y install intel-media-driver
elif echo "$gpu" | grep -i 'nvidia' > /dev/null; then
  sudo dnf -y install libva-nvidia-driver
elif echo "$gpu" | grep -i 'amd' > /dev/null; then
  sudo dnf -y swap mesa-va-drivers mesa-va-drivers-freeworld
  sudo dnf -y swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
fi

# 9. Install flatpak apps
flatpak install --app --noninteractive ${flatpak_apps[@]}

# 10. Docker Desktop
docker_tmp=$(mktemp -d)
curl -L https://desktop.docker.com/linux/main/amd64/153195/docker-desktop-4.31.0-x86_64.rpm --output $docker_tmp/docker-desktop.rpm
sudo dnf -y install $docker_tmp/docker-desktop.rpm

# 11. Add fonts
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
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# 12. Post install dev tasks
sudo usermod -s $(command -v fish) $USER

# docker user
sudo groupadd docker
sudo usermod -aG docker $USER

# aws ecr helper
go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest

# 13. Gnome settings and extensions
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

  busctl --user --timeout=30 call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s $uuid

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
#gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# variable refresh rate
gsettings set org.gnome.mutter experimental-features "['variable-refresh-rate']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'org.mozilla.firefox.desktop', 'google-chrome.desktop', 'com.spotify.Client.desktop', 'discord.desktop', 'steam.desktop', 'com.slack.Slack.desktop', 'md.obsidian.Obsidian.desktop', 'code.desktop', 'docker-desktop.desktop', 'org.gnome.Console.desktop']"

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

# 14. Enable systemd services
for i in ${systemd_services_root[@]}
do
	sudo systemctl enable $i
done

# Done
echo ""
echo  "Fedora Workstation Post-Install Tasks Complete!"
echo "Please run \"systemctl reboot\" to complete post install tasks."
