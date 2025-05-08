#!/usr/bin/env bash

set -eufo pipefail


function _install_build_essentials() {
  # TODO: do it using the right package manager
  echo "🔎 Build essentials are not installed. Installing now..."
  sudo apt-get update
  sudo apt-get install -y build-essential procps git file curl wget xz-utils
}


function _install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "✅ Homebrew is already installed."
    return 0
  fi

  echo "🍺 Homebrew is not installed. Installing now..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  
  # echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc

  # Verify installation
  if command -v brew &>/dev/null; then
    echo "✅ Homebrew installation successful."
  else
    _err "❌ Homebrew installation failed. exiting..."
    exit 1
  fi
}


function _install_linux_stuff() {
  _install_build_essentials
  _install_homebrew
}


function _configure_linux() {
  _install_linux_stuff
}


_configure_linux
