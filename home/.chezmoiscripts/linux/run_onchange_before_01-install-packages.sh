#!/usr/bin/env bash

set -eufo pipefail

if ! command -v brew &>/dev/null; then
  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "❌ Homebrew not found!"
    exit 0
  fi
fi


tap_entries=(
  "sdkman/tap"
)


brew_packages=(
  "awscli"
  "btop"
  "eza"
  # "fish" is a bit slow with starship in git repos!
  "git-delta"
  "golangci-lint"
  "httpie"
  "jj"
  "jless"
  "sdkman-cli"
  "shellcheck"
  # "starship"
  "thefuck"
  "tlrc"
  "tree"
)

cask_packages=(
  "font-menlo-for-powerline"
  "font-meslo-for-powerlevel10k"
)


{
  for tap in "${tap_entries[@]}"; do
    echo "tap \"$tap\""
  done

  for pkg in "${brew_packages[@]}"; do
    echo "brew \"$pkg\""
  done

  for pkg in "${cask_packages[@]}"; do
    echo "cask \"$pkg\""
  done
} | brew bundle --cleanup --file=/dev/stdin
