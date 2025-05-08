#!/usr/bin/env bash

set -eufo pipefail


BIN_DIR=$HOME/.local/bin
CONFIG_DIR=$HOME/.config
OMZ_DIR=${ZDOTDIR:-$HOME}/ohmyzsh
OMZ_PLUGINS_DIR=${OMZ_CUSTOM:-$OMZ_DIR/custom}/plugins

function _patch_kubetail() {
  if [ -f "$CONFIG_DIR/kubetail/kubetail.patch" ]; then
    if [ -d "$OMZ_PLUGINS_DIR/kubetail" ]; then
      echo "ℹ️ Patching kubetail..."
      cd "$OMZ_PLUGINS_DIR/kubetail"
      git reset --hard &>/dev/null && git clean -df &>/dev/null
      git apply "$CONFIG_DIR/kubetail/kubetail.patch"
    else
      echo "⚠️  Kubetail plugin not found in $OMZ_PLUGINS_DIR"
    fi
  fi
}

function _update_custom_aliases() {
  if [[ "${BASH_VERSION:-0}" < "4.0" ]]; then
    echo "⚠️  Bash version 4 or higher is required. Update your Bash and rerun the script."
  elif [[ ! -L "$HOME/.config/alf/alf.conf" || ! -f "$HOME/.config/alf/alf.conf" ]]; then
    echo "⚠️  Alf config not found. Install it and rerun the script."
  else
    echo "ℹ️  Updating custom aliases..."
    ALF_RC_FILE=$HOME/.config/alf/.alfrc ALF_ALIASES_FILE=$HOME/.config/alf/.alf_aliases $HOME/.local/bin/alf save
  fi
}


# _patch_kubetail Outdated!
_update_custom_aliases
