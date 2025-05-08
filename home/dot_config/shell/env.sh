# Shared PATH and tool initialization, sourced by both bash and zsh from
# their interactive rc files. Keep POSIX-compatible: no [[ ]], no zsh-only
# expansions.

export CDK_DISABLE_CLI_TELEMETRY=true

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

if [ -d "/opt/homebrew/bin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export KREW_ROOT="$HOME/.krew"
if [ -d "$KREW_ROOT/bin" ]; then
  export PATH="$KREW_ROOT/bin:$PATH"
fi

export JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"
if [ -d "$JETBRAINS_DIR/Toolbox/scripts" ]; then
  export PATH="$PATH:$JETBRAINS_DIR/Toolbox/scripts"
fi

if command -v brew >/dev/null 2>&1 && brew --prefix sdkman-cli >/dev/null 2>&1; then
  export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"
  [ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ] && . "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# zoxide needs explicit init for bash; zsh gets it via the OMZ zoxide plugin.
if [ -n "${BASH_VERSION:-}" ] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Optional private overlay: symlinked into private/ when that submodule is
# checked out. Holds per-machine values (AWS_DEFAULT_REGION etc.) that don't
# belong in the public repo. Dangling symlinks are silently skipped.
[ -r "$HOME/.config/shell/env.local.sh" ] && . "$HOME/.config/shell/env.local.sh"
