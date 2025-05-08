#!/usr/bin/env bash

set -eufo pipefail


# jq (used below for the devcontainer bootstrap) lives in ~/.local/bin via
# chezmoiexternals; ensure it's on PATH for child processes.
export PATH="$HOME/.local/bin:$PATH"


if command -v claude >/dev/null 2>&1; then
  echo "✅ Claude Code already installed."
else
  echo "🤖 Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi


# Devcontainer-only: seed Claude settings and skip the onboarding flow so the
# CLI is usable immediately when the container comes up.
if [[ "${DEVCONTAINER:-}" == "1" ]]; then
  # Devcontainers mount the project at /workspaces/<repo>. There's always
  # exactly one; $PWD is unreliable here because chezmoi may run scripts
  # from $HOME, not the workspace.
  WORKSPACE=$(find /workspaces -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1 || true)
  if [[ -z "$WORKSPACE" ]]; then
    echo "⚠️  Skipping claude devcontainer bootstrap: no /workspaces/* found."
    exit 0
  fi

  mkdir -p "$HOME/.claude"

  if [[ ! -e "$HOME/.claude/settings.json" ]]; then
    cat > "$HOME/.claude/settings.json" <<'EOF'
{
  "theme": "dark",
  "skipAutoPermissionPrompt": true,
  "permissions": {
    "defaultMode": "auto"
  }
}
EOF
  fi

  [[ -e "$HOME/.claude.json" ]] || echo '{}' > "$HOME/.claude.json"

  tmp=$(mktemp)
  jq --arg ws "$WORKSPACE" '
    .hasCompletedOnboarding = true
    | .lastOnboardingVersion = "999.0.0"
    | .hasIdeOnboardingBeenShown.vscode = true
    | .projects[$ws].hasTrustDialogAccepted = true
    | .projects[$ws].hasCompletedProjectOnboarding = true
  ' "$HOME/.claude.json" > "$tmp" && mv "$tmp" "$HOME/.claude.json"

  echo "✅ Claude devcontainer bootstrap applied for $WORKSPACE."
fi
