#!/usr/bin/env bash

set -eufo pipefail


function _install_rosetta() {
  if [[ `uname -m` == "arm64" ]] ; then
    if ! (arch -arch x86_64 uname -m > /dev/null) ; then
      echo "🔎 Rosetta is not installed. Installing now..."
      softwareupdate --install-rosetta --agree-to-license
    else
      echo "✅ Rosetta is already installed."
    fi
  fi
}


function _install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "✅ Homebrew is already installed."
    return 0
  fi

  echo "🍺 Homebrew is not installed. Installing now..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # Verify installation
  if command -v brew &>/dev/null; then
    echo "✅ Homebrew installation successful."
  else
    _err "❌ Homebrew installation failed. exiting..."
    exit 1
  fi
}


function _install_darwin_stuff() {
  _install_rosetta
  _install_homebrew
}


function _configure_darwin() {
  _install_darwin_stuff
}


_configure_darwin
