#!/usr/bin/env bash
# Post-install verification. Walks every tool the dotfiles claim to provide
# on Linux and checks the binary is on PATH and `--version` (or equivalent)
# returns. Exits non-zero on any failure.

set -uo pipefail

# Pick up Homebrew (Linuxbrew) so the brew-installed binaries are visible.
# The install scripts only run brew shellenv in their own subshell, so any
# new shell (this one) has to do it again.
if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -d "/opt/homebrew/bin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

PATH="$HOME/.local/bin:$PATH"

fail=0
pass=0

check() {
  local name="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf '  \xe2\x9c\x85 %s\n' "$name"
    pass=$((pass + 1))
  else
    printf '  \xe2\x9d\x8c %s  (cmd: %s)\n' "$name" "$cmd"
    fail=$((fail + 1))
  fi
}

echo "==> verifying tools on PATH"

# Tools from chezmoiexternals (downloaded directly).
check act         "act --version"
check aws-sso     "aws-sso version"
check bat         "bat --version"
check fd          "fd --version"
check fx          "fx --help"
check fzf         "fzf --version"
check gh          "gh --version"
check gdu         "gdu --version"
check helm        "helm version --client --short"
check jq          "jq --version"
check k6          "k6 version"
check k9s         "k9s version"
check kubectl-134 "kubectl-134 version --client=true"
check rg          "rg --version"
check sd          "sd --version"
check terraform   "terraform version"
check uv          "uv --version"
check uvx         "uvx --version"
check zoxide      "zoxide --version"

# Tools from Homebrew.
check aws         "aws --version"
check btop        "btop --version"
check delta       "delta --version"
check eza         "eza --version"
check httpie      "http --version"
check shellcheck  "shellcheck --version"
check tree        "tree --version"

echo
echo "==> verifying shared shell config"
check shell-env        "test -f \"$HOME/.config/shell/env.sh\""
check shell-aliases    "test -f \"$HOME/.config/shell/aliases.sh\""
check shell-functions  "test -f \"$HOME/.config/shell/functions.sh\""

echo
echo "==> verifying zsh config"
check zshenv  "test -L \"$HOME/.zshenv\""
check zshrc   "test -f \"$HOME/.config/zsh/.zshrc\""
check ohmyzsh "test -d \"$HOME/.config/zsh/ohmyzsh\""
check p10k    "test -d \"$HOME/.config/ohmyzsh/custom/themes/powerlevel10k\""
check git     "git --version"
# sdkman-cli is a brew formula; check the init script in its libexec.
check sdkman  "test -s \"$(brew --prefix sdkman-cli)/libexec/bin/sdkman-init.sh\""

echo
echo "==> verifying git identity"
# Don't assert specific values — Q's machine and the Docker harness will
# legitimately differ. Just confirm install.sh / chezmoi populated something.
check git-user-name  "git config --global user.name  | grep -q ."
check git-user-email "git config --global user.email | grep -q ."

echo
echo "==> verifying bash config"
# The modify_ script appends a marker-delimited block to whatever ~/.bashrc
# already exists (or creates one if missing). Confirm the block is present
# and that an interactive bash actually loads the shared aliases / PATH.
check bashrc-exists    "test -f \"$HOME/.bashrc\""
check bashrc-marker    "grep -q '# >>> dotfiles shared shell >>>' \"$HOME/.bashrc\""
check bash-alias-k       "bash -ic 'alias k' 2>/dev/null | grep -q kubectl"
check bash-eza-on-path   "bash -ic 'command -v eza' >/dev/null"
check bash-delta-on-path "bash -ic 'command -v delta' >/dev/null"
check bash-cd-z-defined  "bash -ic 'type z' >/dev/null 2>&1"

echo
echo "==> $pass passed, $fail failed"
exit $((fail > 0 ? 1 : 0))
