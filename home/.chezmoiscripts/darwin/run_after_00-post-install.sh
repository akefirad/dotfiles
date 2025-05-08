#!/usr/bin/env bash

set -eufo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BIN_DIR=$HOME/.local/bin
CONFIG_DIR=$HOME/.config
OMZ_DIR=${ZDOTDIR:-$HOME}/ohmyzsh
OMZ_PLUGINS_DIR=${OMZ_CUSTOM:-$OMZ_DIR/custom}/plugins

if [ -f "$CONFIG_DIR/kubetail/kubetail.patch" ]; then
  if [ -d "$OMZ_PLUGINS_DIR/kubetail" ]; then
    echo "Patching kubetail..."
    cd "$OMZ_PLUGINS_DIR/kubetail"
    git reset --hard &>/dev/null && git clean -df &>/dev/null
    git apply "$CONFIG_DIR/kubetail/kubetail.patch"
  else
    echo "⚠️  Kubetail plugin not found"
  fi
fi

if [[ "${BASH_VERSION:-0}" < "4.0" ]]; then
  echo "⚠️  Bash version is less than 4, skipping update of custom aliases"
else
  echo "Updating custom aliases..."
  /Users/rad/.local/bin/alf save > /dev/null
fi
