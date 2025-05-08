#!/usr/bin/env bash

set -eufo pipefail


CONFIG_DIR="$HOME/.config"
# ohmyzsh is fetched as a chezmoiexternals git-repo under $ZDOTDIR (see
# .chezmoiexternals/shared.yaml.tmpl). The ZDOTDIR env var isn't exported
# during chezmoi script runs, so hardcode the path we install to.
OMZ_PLUGINS_DIR="${OMZ_CUSTOM:-$CONFIG_DIR/ohmyzsh/custom}/plugins"

# The kubetail patch is outdated (does not apply against current upstream).
# Matches the darwin script which has it disabled for the same reason.
# if [ -f "$CONFIG_DIR/kubetail/kubetail.patch" ] && [ -d "$OMZ_PLUGINS_DIR/kubetail" ]; then
#   echo "ℹ️ Patching kubetail..."
#   (
#     cd "$OMZ_PLUGINS_DIR/kubetail"
#     git reset --hard >/dev/null
#     git clean -df >/dev/null
#     git apply "$CONFIG_DIR/kubetail/kubetail.patch"
#   )
# fi
