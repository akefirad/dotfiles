#!/usr/bin/env bash

set -eufo pipefail

if ! command -v brew &>/dev/null; then
  if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "❌ Homebrew not found!"
    exit 0
  fi
fi


tap_entries=(
  "sdkman/tap"
)

# Fish is a bit slow with starship in git repos!
brew_packages=(
  "awscli"
  "bash"
  "btop"
  "curl"
  "displayplacer"
  "dockutil"
  "eza"
  "ffmpeg"
  # "fish"
  "git-delta"
  "git"
  "go"
  "golangci-lint"
  "httpie"
  "jj"
  "jless"
  "kubectx"
  "mas"
  "sdkman-cli"
  "shellcheck"
  # "starship"
  "thefuck"
  "tlrc"
  "tree"
  "wget"
  "xz"
  "yt-dlp"
)

cask_packages=(
  "cursor"
  "docker-desktop"
  "firefox"
  "font-menlo-for-powerline"
  "font-meslo-for-powerlevel10k"
  "fork"
  "freelens"
  "ghostty"
  "google-chrome"
  "jetbrains-toolbox"
  "lapce"
  "microsoft-edge"
  "notion"
  "orka-desktop"
  "raycast"
  "slack"
  "superwhisper"
  "stolendata-mpv"
  "telegram"
  "the-unarchiver"
  "whatsapp"
  "visual-studio-code"
  "vlc"
  "windsurf"
  # "zen"
  "zoom"
  # "1password-cli"
  # "hammerspoon"
  # "karabiner-elements"
  # "tailscale"
  # "transmission"
)

if defaults read MobileMeAccounts Accounts &>/dev/null; then
  mas_apps=(
    "AdGuard for Safari: 1440147259"
    "GitHub Refined:     1519867270"
    "Step Two:           1448916662"
  )
else
  echo "⚠️  No Apple account found. Skipping Mac App Store apps."
  mas_apps=()
fi

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

  if [[ ${#mas_apps[@]} -gt 0 ]]; then
    for entry in "${mas_apps[@]}"; do
      name="${entry%%:*}"
      id="${entry##*:}"
      echo "mas \"$name\", id: $id"
    done
  fi
} | brew bundle --cleanup --file=/dev/stdin
