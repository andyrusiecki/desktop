#!/bin/bash

while getopts 'hd:p:' opt; do
  case "$opt" in
    d)
      arg="$OPTARG"
      if [[ "$arg" == "framework" ]]; then
        device="$arg"
      fi
      ;;

    p)
      arg="$OPTARG"
      if [[ "$arg" == "sway" ]]; then
        profile="$arg"
      fi
      ;;

    ?|h)
      echo "Usage: $(basename $0) [-v] [-d device] [-p profile]"
      echo -e "-d <device>\t runs additional tasks based on the device (available devices: framework)"
      echo -e "-p <profile>\t runs additional tasks based on the profile (available profiles: sway)\n"
      exit 1
      ;;
  esac
done

root=$(dirname $(realpath $0))

packages=(
  # base
  vim

  # shell
  fish
  starship

  # font dependencies
  curl
  cabextract
  xorg-x11-font-utils
  fontconfig

  # development
  amazon-ecr-credential-helper # TODO: install via golang
  awscli
  docker-compose
  golang
  jq
  kubectl
  make
  moby-engine
  python3-pip

  # Other applications
  code
  discord
  google-chrome-stable
  libreoffice
  steam
)

flatpak_apps=(
  com.getpostman.Postman
  com.github.tchx84.Flatseal
  com.mattjakeman.ExtensionManager
  com.slack.Slack
  com.spotify.Client
  com.usebottles.bottles
  io.github.realmazharhussain.GdmSettings
  net.cozic.joplin_desktop
  org.gnome.World.PikaBackup
  org.gtk.Gtk3theme.adw-gtk3
  org.signal.Signal
  us.zoom.Zoom
)

systemd_services_root=(
  docker
)
echo "Starting Fedora Workstation Post-Install Tasks..."

# 1. Update dnf conf
sudo echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf

# 2. update current packages
sudo dnf update -y --refresh

# 2. Install Snapper and dnf plugin
sudo dnf install -y snapper python3-dnf-plugins-extras-snapper
sudo snapper --config=root create-config /

# 3. Enable RPM fusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core

# 4. Add COPR repos
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo cp $root/assets/starship.repo /etc/yum.repos.d/
sudo cp $root/assets/kubernetes.repo /etc/yum.repos.d/
sudo cp $root/assets/vscode.repo /etc/yum.repos.d/

# 5. Install Multimedia codes
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate sound-and-video

# 6. Profile
case $profile in
  sway)
    packages+=(
      brightnessctl
      dunst
      gammastep
      grimshot
      kitty
      playerctl
      sway
      swaybg
      swayidle
      swaylock
      waybar
      wofi
    )
    ;;
esac

# 7. Device
case $device in
  framework)
    packages+=(
      # graphics
      intel-media-driver
    )

    # fixing brightness keys
    sudo grubby --update-kernel=ALL --args="module_blacklist=hid_sensor_hub"

    # improve NVMe power saving
    sudo grubby --update-kernel=ALL --args="nvme.noacpi=1"

    # fixing screen freezes
    sudo grubby --update-kernel=ALL --args="i915.enable_psr=0"
    ;;
esac

# 8. Install packages
sudo dnf install -y ${packages[@]}

# 9. Install flatpak apps
flatpak install --noninteractive ${flatpak_apps[@]}

mkdir -p ~/.local/share/applications
# slack
sed 's/@@u %U @@/--enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer --ozone-platform=wayland @@u %U @@/g' /var/lib/flatpak/exports/share/applications/com.slack.Slack.desktop > ~/.local/share/applications/com.slack.Slack.desktop

# postman
sed 's/@@u %U @@/--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland @@u %U @@/g' /var/lib/flatpak/exports/share/applications/com.getpostman.Postman.desktop > ~/.local/share/applications/com.getpostman.Postman.desktop

# 10. Copy config files
# shell
mkdir -p ~/.config/fish/
cp $root/assets/config.fish ~/.config/fish/
cp $root/assets/starship.toml ~/.config/

# AWS ECR helper config
mkdir ~/.docker
cp $root/assets/docker-config.json ~/.docker/config.json

# 11. Add themes
mkdir -p ~/.local/share/themes/

tmp_dir=$(mktemp -d)
curl -L https://github.com/lassekongo83/adw-gtk3/releases/download/v4.5/adw-gtk3v4-5.tar.xz --output $tmp_dir/adw-gtk3v4-5.tar.xz
tar -xf $tmp_dir/adw-gtk3v4-5.tar.xz -C ~/.local/share/themes/
rm -rf $tmp_dir

# 12. Add fonts
mkdir -p ~/.local/share/fonts/

tmp_dir=$(mktemp -d)
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip --output $tmp_dir/JetBrainsMono.zip
unzip $tmp_dir/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
rm -rf $tmp_dir

# ms fonts
sudo dnf install -y curl cabextract xorg-x11-font-utils fontconfig
$ sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

# 12. Post install tasks
chsh -s $(command -v fish)

# docker user
sudo groupadd docker
sudo usermod -aG docker $USER

# aws ecr helper
go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest

# pywal
sudo pip3 install pywal

# gnome extensions
extensions=(
  AlphabeticalAppGrid@stuarthayhurst
  appindicatorsupport@rgcjonas.gmail.com
  bluetooth-quick-connect@bjarosze.gmail.com
  blur-my-shell@aunetx
  mediacontrols@cliffniff.github.com
  notification-banner-reloaded@marcinjakubowski.github.com
  nightthemeswitcher@romainvigier.fr
  no-overview@fthx
  pip-on-top@rafostar.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
  Vitals@CoreCoding.com
)

shell_version=$(gnome-shell --version | cut -d' ' -f3)

for uuid in ${extensions[@]}
do
  info_json=$(curl -sS "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_version")
  download_url=$(echo $info_json | jq ".download_url" --raw-output)

  gnome-extensions install "https://extensions.gnome.org$download_url"
  gnome-extensions enable $uuid
done

# gnome dconf settings
gsettings set org.gnome.desktop.datetime automatic-timezone true

gsettings set org.gnome.desktop.interface clock-format "12h"
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
gsettings set org.gnome.desktop.interface font-hinting "slight"
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3"

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<SHIFT><SUPER>1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<SHIFT><SUPER>2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<SHIFT><SUPER>3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<SHIFT><SUPER>4']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<SHIFT><SUPER>5']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<SHIFT><SUPER>6']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<SHIFT><SUPER>7']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-8 "['<SHIFT><SUPER>8']"

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<SUPER>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<SUPER>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<SUPER>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<SUPER>4']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<SUPER>5']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<SUPER>6']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<SUPER>7']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-8 "['<SUPER>8']"

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true

gsettings set org.gnome.system.location enabled true

gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'org.mozilla.firefox.desktop', 'com.google.Chrome.desktop', 'com.spotify.Client.desktop', 'com.valvesoftware.Steam.desktop', 'com.slack.Slack.desktop', 'net.cozic.joplin_desktop.desktop', 'com.visualstudio.code.desktop', 'org.gnome.Terminal.desktop']"

# TODO: extension settings

# 13. Enable systemd services
for i in ${systemd_services_root[@]}
do
	sudo systemctl enable $i
done

# Done
echo -e "\nFedora Workstation Post-Install Tasks Complete!\n"

echo -n "Restarting in "
for i in {5..1}
do
  echo -n "$i..."
  sleep 1
done

systemctl reboot
