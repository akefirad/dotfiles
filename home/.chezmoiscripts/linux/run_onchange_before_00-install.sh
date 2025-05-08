#!/usr/bin/env bash

set -eufo pipefail


function _install_build_essentials() {
  # Skip if every binary is already present — keeps this a no-op on
  # machines with a dev toolchain so we don't require sudo when we
  # wouldn't actually do anything.
  local missing=0
  # procps and xz-utils provide binaries with different names; check those.
  for cmd in cc make ps git file curl wget xz zsh; do
    command -v "$cmd" >/dev/null 2>&1 || missing=1
  done
  if [[ "$missing" -eq 0 ]]; then
    echo "✅ Build essentials already present."
    return 0
  fi

  echo "🔎 Build essentials missing. Installing now..."
  # `sudo -n` avoids hanging when there is no tty for password entry.
  if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y build-essential procps git file curl wget xz-utils zsh
  elif [[ "$(id -u)" -eq 0 ]]; then
    apt-get update
    apt-get install -y build-essential procps git file curl wget xz-utils zsh
  else
    echo "❌ Cannot install build essentials: not root and no passwordless sudo." >&2
    echo "   Install manually: build-essential procps git file curl wget xz-utils zsh" >&2
    exit 1
  fi
}


function _install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "✅ Homebrew is already installed."
    return 0
  fi

  echo "🍺 Homebrew is not installed. Installing now..."
  # NONINTERACTIVE=1 stops the installer from prompting for sudo passwords
  # and confirmation; it still requires passwordless sudo to write to
  # /home/linuxbrew. Without this, the bootstrap hangs in CI/Docker.
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew installation failed." >&2
    exit 1
  fi
  echo "✅ Homebrew installation successful."
}


_install_build_essentials
_install_homebrew
