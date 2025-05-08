#!/usr/bin/env bash

set -eufo pipefail


function _install_nvm() {
  if [ -d "$HOME/.nvm" ]; then
    echo '✅ nvm is already installed. To re-install it, first run rm -rf "$HOME/.nvm"'
    return 0
  fi

  echo "ℹ️  nvm is not installed. Installing now..."

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  # TODO: Verify installation
}


function _install_krew() {
  if [ -d "$HOME/.krew" ]; then
    echo '✅ krew is already installed. To re-install it, first run rm -rf "$HOME/.krew"'
    return 0
  fi

  echo "ℹ️  krew is not installed. Installing now..."
  (
    set -x; cd "$(mktemp -d)" &&
    _os="$(uname | tr '[:upper:]' '[:lower:]')" &&
    _arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    _krew="krew-${_os}_${_arch}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${_krew}.tar.gz" &&
    tar zxvf "${_krew}.tar.gz" &&
    ./"${_krew}" install krew
  )
}


function _install_seabird() {
  if [[ -d "$HOME/Applications/Seabird.app" ]]; then
    echo "Seabird is already installed."
    return 0
  fi

  echo "Installing Seabird..."
  curl -L https://github.com/getseabird/seabird/releases/download/v0.5.1/seabird_darwin_arm64.dmg -o /tmp/seabird.dmg
  hdiutil attach -quiet /tmp/seabird.dmg
  cp -r /Volumes/Seabird/Seabird.app "$HOME/Applications"
  hdiutil detach /Volumes/Seabird
  rm /tmp/seabird.dmg
}


function _install_immersed() {
  if [[ -d "$HOME/Applications/Immersed.app" ]]; then
    echo "Immersed is already installed."
    return 0
  fi

  echo "Installing Immersed..."
  curl -L https://static.immersed.com/dl/Immersed.dmg -o /tmp/immersed.dmg
  hdiutil attach -quiet /tmp/immersed.dmg
  cp -r '/Volumes/Immersed Installer/Immersed.app' "$HOME/Applications"
  hdiutil detach '/Volumes/Immersed Installer'
  rm /tmp/immersed.dmg
}


_install_nvm
_install_krew
_install_seabird
# _install_immersed Doesn't seem to work!
