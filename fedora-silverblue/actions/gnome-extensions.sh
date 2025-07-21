#!/bin/bash

set -euo pipefail

basedir=$(dirname $(realpath $0))
source $basedir/../../shared/bootstrap.sh

taskLog "Gnome Extensions"

taskItem "installing extensions"

added_extensions=(
  app-hider@lynith.dev
  AlphabeticalAppGrid@stuarthayhurst
  nightthemeswitcher@romainvigier.fr
  pip-on-top@rafostar.github.com
  spotify-controls@Sonath21
  system-monitor@gnome-shell-extensions.gcampax.github.com
  tailscale@joaophi.github.com
  user-theme@gnome-shell-extensions.gcampax.github.com
)

if ! command -v gnome-shell &> /dev/null; then
  echo "ERROR: gnome-shell is not installed."
  exit 1
fi

echo "Testing connection with https://extensions.gnome.org/..."
if ! curl --output /dev/null --silent --head --fail "https://extensions.gnome.org/"; then
  echo "ERROR: Connection unsuccessful."
  exit 1
else
  echo "Connection successful, proceeding."
fi


gnome_version=$(gnome-shell --version | sed 's/[^0-9]*\([0-9]*\).*/\1/')
echo "Gnome version: ${gnome_version}"

tmp_dir=$(mktemp -d)
ext_base_dir="$HOME/.local/share/gnome-shell/extensions"


for ext_uuid in ${added_extensions[@]}; do
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
  archive=$(basename "${extension_url}")
  archive_dir="${tmp_dir}/${archive}"

  echo "Installing '${ext_uuid}' Gnome extension with version ${ext_ver}"

  # Download archive
  curl -fLs --create-dirs "${extension_url}" -o "${archive_dir}"

  # Extract archive
  unzip "${archive_dir}" -d "${ext_base_dir}/${ext_uuid}" > /dev/null

  # Remove archive
  rm "${archive_dir}"

  glib-compile-schemas "${ext_base_dir}/${ext_uuid}/schemas/" &>/dev/null

  echo "Extension '${ext_uuid}' is successfully installed"
done

rm -r "${tmp_dir}"

taskItem "updating extension settings"

gsettings set org.gnome.shell.extensions.caffeine nightlight-control 'always'

gsettings set org.gnome.shell.extensions.just-perfection notification-banner-position 2

gsettings set org.gnome.shell.extensions.nightthemeswitcher.time manual-schedule true
gsettings set org.gnome.shell.extensions.nightthemeswitcher.time sunrise 6.0
gsettings set org.gnome.shell.extensions.nightthemeswitcher.time sunset 18.0

gsettings set org.gnome.shell.extensions.pip-on-top stick true
