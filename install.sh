#!/bin/sh

set -e # -e: exit on error

if [ ! "$(command -v chezmoi)" ]; then
  bin_dir="$HOME/.local/bin"
  chezmoi="$bin_dir/chezmoi"
  if [ "$(command -v curl)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$bin_dir"
  elif [ "$(command -v wget)" ]; then
    sh -c "$(wget -qO- https://git.io/chezmoi)" -- -b "$bin_dir"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi
else
  chezmoi=chezmoi
fi

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# First-install configuration: derive identity from the repo and pre-populate
# the chezmoi config so its promptStringOnce calls don't fire. Skipped on
# re-runs (existing config) so values aren't overwritten. To reconfigure,
# delete ~/.config/chezmoi/chezmoi.yaml and re-run.
chezmoi_config="$HOME/.config/chezmoi/chezmoi.yaml"
if [ ! -f "$chezmoi_config" ]; then
  owner=""
  remote_url=$(git -C "$script_dir" remote get-url origin 2>/dev/null || true)
  if [ -n "$remote_url" ]; then
    owner=$(printf '%s' "$remote_url" | sed -E 's@.*[:/]([^/]+)/[^/]+(\.git)?$@\1@')
  fi

  git_name="${owner:-Anonymous}"

  git_email=""
  if [ -n "$owner" ]; then
    git_email=$(git -C "$script_dir" log --author="$owner" -1 --format='%ae' 2>/dev/null || true)
  fi
  [ -z "$git_email" ] && git_email="${git_name}@localhost"

  p10k_repo="https://github.com/romkatv/powerlevel10k.git"
  if [ -n "$owner" ]; then
    candidate="https://github.com/$owner/powerlevel10k.git"
    if git ls-remote --exit-code "$candidate" HEAD >/dev/null 2>&1; then
      p10k_repo="$candidate"
    fi
  fi

  # Interactive: show derived defaults, let the user override. Non-interactive
  # runs (Docker harness, CI) silently take the derived values.
  if [ -t 0 ] && [ -t 1 ]; then
    printf 'Git user.name [%s]: '          "$git_name";  read input || true; [ -n "$input" ] && git_name="$input"
    printf 'Git user.email [%s]: '         "$git_email"; read input || true; [ -n "$input" ] && git_email="$input"
    printf 'Powerlevel10k repo URL [%s]: ' "$p10k_repo"; read input || true; [ -n "$input" ] && p10k_repo="$input"
  fi

  mkdir -p "$(dirname "$chezmoi_config")"
  cat > "$chezmoi_config" <<EOF
data:
  git:
    name: "$git_name"
    email: "$git_email"
  p10k:
    repo: "$p10k_repo"
EOF
fi

# exec: replace current process with chezmoi init
exec "$chezmoi" init --apply "--source=$script_dir"
