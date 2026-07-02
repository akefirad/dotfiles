# Issue tracker: GitHub

Issues and PRDs live as GitHub issues. Use the `gh` CLI for all operations.

## This repo is a multi-repo workspace — pick the right repo first

This working tree is a superproject with several submodules, each backed by its
own GitHub repo. **Before creating or filing an issue, determine which
submodule the work touches and target that repo.** Never assume the root.

| Path in this tree              | GitHub repo              |
| ------------------------------ | ------------------------ |
| `.` (root)                     | `akefirad-418/dotfiles`  |
| `clawtilla`                    | `akefirad/clawtilla`     |
| `private`                      | `akefirad/.dotfiles`     |
| `private/clawtilla/private`    | `akefirad-418/.dotfiles` |
| `private/clawtilla/clawpatrol` | `akefirad/clawpatrol`    |

Vendored third-party submodules under `oss/` (chezmoi, hermes-agent,
aws-sso-cli) are **not** our trackers — never file issues there.

To target a specific repo, pass `--repo <owner>/<name>` to every `gh` command
(e.g. `gh issue create --repo akefirad/clawtilla ...`). If the affected repo is
ambiguous, ask before creating.

## Conventions

- **Create an issue**: `gh issue create --repo <owner>/<name> --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --repo <owner>/<name> --comments`.
- **List issues**: `gh issue list --repo <owner>/<name> --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --repo <owner>/<name> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --repo <owner>/<name> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --repo <owner>/<name> --comment "..."`

## Pull requests as a triage surface

**PRs as a request surface: no.** `/triage` handles issues only; external PRs
are ignored.

## When a skill says "publish to the issue tracker"

Determine the target repo from the table above, then create a GitHub issue there.

## When a skill says "fetch the relevant ticket"

Run `gh issue view <number> --repo <owner>/<name> --comments`.
