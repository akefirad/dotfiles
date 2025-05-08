#!/usr/bin/env bash

set -eufo pipefail

CONFIG_DIR=$HOME/.config
OH_MY_ZSH_DIR=${ZDOTDIR:-$HOME}/ohmyzsh


function _install_nvm() {
  # if command -v nvm &>/dev/null; then  # This doesn't work,
  if [ -d "$HOME/.nvm" ]; then           # because PATH is not set yet!
    echo "✅ nvm is already installed."
    return 0
  fi

  echo "ℹ️  nvm is not installed. Installing now..."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  # TODO: Verify installation
}


function _install_krew() {
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
}

function _install_seabird() {
  # Seabird, TODO: migrate to brew when it's available
  if [[ ! -d "$HOME/Applications/Seabird.app" ]]; then
    echo "Installing Seabird..."
    curl -L https://github.com/getseabird/seabird/releases/download/v0.5.1/seabird_darwin_arm64.dmg -o /tmp/seabird.dmg
    hdiutil attach /tmp/seabird.dmg
    cp -r /Volumes/Seabird/Seabird.app "$HOME/Applications"
    hdiutil detach /Volumes/Seabird
    rm /tmp/seabird.dmg
  fi
}


_install_nvm
_install_krew
_install_seabird