#!/bin/bash

set -euo pipefail

function install_nerd_fonts() {
  fonts=(
    AdwaitaMono
    FiraCode
    FiraMono
    Hack
    Meslo
    RobotoMono
    SourceCodePro
  )

  tmp_dir=$(mktemp -d)
  base_dir="$HOME/.local/share/fonts"

  mkdir -p $base_dir

  for font in ${fonts[@]}
  do
    fontname="nerd-$(echo "$font" | sed 's/[A-Z]/-\l&/g' | sed 's/^-//')"
    fontdir="$base_dir/$fontname"

    curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz --output $tmp_dir/$font.tar.xz &> /dev/null

    if [ -d "$fontdir" ]; then
      rm -r $fontdir
    fi

    mkdir -p $fontdir
    tar -xf $tmp_dir/$font.tar.xz  -C $fontdir/

    echo "Added Nerd Font: $font"
  done

  rm -rf $tmp_dir
}

function install_ms_fonts() {
  fonts=(
    andale32
    arial32
    arialb32
    comic32
    courie32
    georgi32
    impact32
    times32
    trebuc32
    verdan32
    webdin32
  )

  tmp_dir="$HOME/.cache/ms-fonts"
  base_dir="$HOME/.local/share/fonts"

  mkdir -p $base_dir
  mkdir -p $tmp_dir

  distrobox create --name tmp-ms-fonts --additional-packages cabextract

  for font in ${fonts[@]}
  do
    fontdir="$base_dir/ms-$font"

    curl -L http://downloads.sourceforge.net/corefonts/$font.exe --output $tmp_dir/$font.exe &> /dev/null

    if [ -d "$fontdir" ]; then
      rm -r $fontdir
    fi

    mkdir -p $fontdir
    distrobox-enter --name tmp-ms-fonts -- cabextract -d $fontdir/ $tmp_dir/$font.exe

    echo "Added Micosoft Font: $font"
  done

  rm -rf $tmp_dir
  distrobox stop -yes tmp-ms-fonts
  distrobox rm --force tmp-ms-fonts
}

function install_gnome_extensions() {
  if ! command -v gnome-shell &> /dev/null; then
    echo "gnome-shell is not installed."
    exit 1
  fi

  if ! curl --output /dev/null ----head --fail "https://extensions.gnome.org/"; then
    echo "ERROR: Connection unsuccessful."
    exit 1
  fi

  extensions=(
    app-hider@lynith.dev
    # TODO: AppIndicator
    AlphabeticalAppGrid@stuarthayhurst
    # TODO: caffeine
    # TODO: just perfection
    nightthemeswitcher@romainvigier.fr
    pip-on-top@rafostar.github.com
    spotify-controls@Sonath21
    system-monitor@gnome-shell-extensions.gcampax.github.com
    user-theme@gnome-shell-extensions.gcampax.github.com
  )

  gnome_version=$(gnome-shell --version | sed 's/[^0-9]*\([0-9]*\).*/\1/')

  tmp_dir=$(mktemp -d)
  ext_base_dir="$HOME/.local/share/gnome-shell/extensions"

  mkdir -p $ext_base_dir

  for ext_uuid in ${extensions[@]}; do
    ext_json=$(curl -sf "https://extensions.gnome.org/extension-query/?uuid=${ext_uuid}" | jq ".extensions[] | select(.uuid == \"${ext_uuid}\")")
    if [[ -z "${ext_json}" ]] || [[ "${ext_json}" == "null" ]]; then
      echo "ERROR: Extension '${ext_uuid}' does not exist in https://extensions.gnome.org/ website"
      exit 1
    fi

    ext_ver=$(echo "${ext_json}" | jq ".shell_version_map[\"${gnome_version}\"].version")
    if [[ -z "${ext_ver}" ]] || [[ "${ext_ver}" == "null" ]]; then
      echo "ERROR: Extension '${ext_uuid}' is not compatible with Gnome v${gnome_version} in your image"
      echo "Skipping installation of '${ext_uuid}' extension"
      continue
    fi

    extension_url="https://extensions.gnome.org/extension-data/${ext_uuid//@/}.v${ext_ver}.shell-extension.zip"
    ext_tmp_dir="${tmp_dir}/${ext_uuid}"
    archive=$(basename "${extension_url}")
    archive_dir="${tmp_dir}/${archive}"

    # Download archive
    curl -fLs --create-dirs "${extension_url}" -o "${archive_dir}"

    # Extract archive
    unzip "${archive_dir}" -d "${ext_tmp_dir}"

    # Remove archive
    rm "${archive_dir}"

    # Install main extension files
    install -d -m 0755 "${ext_base_dir}/${ext_uuid}/"
    find "${ext_tmp_dir}" -mindepth 1 -maxdepth 1 ! -path "*locale*" ! -path "*schemas*" -exec cp -r {} "${ext_base_dir}/${ext_uuid}/" \;
    find "${ext_base_dir}/${ext_uuid}" -type d -exec chmod 0755 {} +
    find "${ext_base_dir}/${ext_uuid}" -type f -exec chmod 0644 {} +

    # Install schemas
    if [[ -d "${ext_tmp_dir}/schemas" ]]; then
      install -d -m 0755 "$HOME/.local/share/glib-2.0/schemas/"
      install -D -p -m 0644 "${ext_tmp_dir}/schemas/"*.gschema.xml "$HOME/.local/share/glib-2.0/schemas/"
    fi

    # Install languages
    if [[ -d "${ext_tmp_dir}/locale/" ]]; then
      if find "${ext_tmp_dir}/locale/" -type f -name "*.mo" -print -quit | read; then
        install -d -m 0755 "$HOME/.local/share/locale/"
        cp -r "${ext_tmp_dir}/locale"/* "$HOME/.local/share/locale/"
      fi
    fi

    # Delete the temporary directory
    rm -r "${ext_tmp_dir}"
    echo "Added Gnome Extension: '${ext_uuid}' v${ext_ver}"
  done

  rm -r "${tmp_dir}"
}

# enable flathub
flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# replace fedora flatpaks
if flatpak list --columns=application | grep org.fedoraproject.MediaWriter &>/dev/null; then
  echo "Removing Fedora Media Writer flatpak."
  flatpak remove --noninteractive org.fedoraproject.MediaWriter
fi

num_fedora_flatpaks=$(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 | wc -l)
if [ "$num_fedora_flatpaks" -gt 0 ]; then
  echo "Found $num_fedora_flatpaks Fedora flatpaks. Reinstalling from Flathub"
  flatpak install --noninteractive --reinstall flathub $(flatpak list --app-runtime=org.fedoraproject.Platform --columns=application | tail -n +1 )
fi

if flatpak remotes | grep --quiet fedora; then
  echo "Removing Fedora flatpak remote."
  # removed pins and unused flatpaks
  flatpak pin | xargs -n 1 -t flatpak pin --remove
  flatpak remove --unused --noninteractive

  # remove fedora remote
  flatpak remote-delete fedora
fi

# install flatpaks
flatpak_apps=(
  com.discordapp.Discord
  com.dec05eba.gpu_screen_recorder
  com.getpostman.Postman
  com.github.marhkb.Pods
  com.github.mtkennerly.ludusavi
  com.github.tchx84.Flatseal
  com.google.Chrome
  com.mattjakeman.ExtensionManager
  com.nextcloud.desktopclient.nextcloud
  com.onepassword.OnePassword
  com.slack.Slack
  com.spotify.Client
  com.valvesoftware.Steam
  com.visualstudio.code
  dev.qwery.AddWater
  io.github.Foldex.AdwSteamGtk
  io.github.celluloid_player.Celluloid
  io.github.realmazharhussain.GdmSettings
  it.mijorus.gearlever
  md.obsidian.Obsidian
  org.gnome.Boxes
  org.gnome.World.PikaBackup
  org.libreoffice.LibreOffice
  org.mozilla.firefox
  org.signal.Signal
  us.zoom.Zoom
)

flatpak_runtimes=(
  org.gtk.Gtk3theme.adw-gtk3
  org.gtk.Gtk3theme.adw-gtk3-dark
  org.freedesktop.Platform.VulkanLayer.MangoHud//25.08
)

echo "Installing new flatpak apps and runtimes from flathub."
flatpak install --or-update --noninteractive --app ${flatpak_apps[@]}
flatpak install --or-update --noninteractive --runtime ${flatpak_runtimes[@]}

echo "Enabling podman socket"
systemctl --user enable --now podman.socket

echo "Installing fonts"
install_nerd_fonts
install_ms_fonts

echo "Installing gnome extensions"
install_gnome_extensions
echo "Removing unneeded packages"
rpm-ostree override remove \
  firefox \
  firefox-langpacks \
  toolbox

echo "Adding new packages"
rpm-ostree install \
  adw-gtk3-theme \
  distrobox \
  steam-devices \
  tailscale

echo "Reboot to apply changes"
echo "Note: You'll need to enable the tailscale service after rebooting with 'sudo systemctl enable --now tailscaled.service'"
