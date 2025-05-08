#!/usr/bin/env bash

set -eufo pipefail


# Put brew on PATH in case the previous chezmoi script that installed it ran
# in a separate process (chezmoi spawns each script fresh).
if ! command -v brew >/dev/null 2>&1; then
  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "❌ Homebrew not found." >&2
    exit 1
  fi
fi


tap_entries=(
  "sdkman/tap"
)


# Intentionally absent (decided during the linux audit):
# - golangci-lint, jj, jless, tlrc, thefuck — skipped per user instruction.
brew_packages=(
  "awscli"
  "btop"
  "eza"
  "git-delta"
  "httpie"
  "opencode"
  "sdkman-cli"
  "shellcheck"
  "tree"
)


{
  for tap in "${tap_entries[@]}"; do
    echo "tap \"$tap\""
  done

  for pkg in "${brew_packages[@]}"; do
    echo "brew \"$pkg\""
  done
} | brew bundle --cleanup --file=/dev/stdin
