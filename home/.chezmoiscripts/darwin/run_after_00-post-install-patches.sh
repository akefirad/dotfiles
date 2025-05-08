#!/usr/bin/env bash

set -eufo pipefail


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


# _patch_kubetail Outdated!
