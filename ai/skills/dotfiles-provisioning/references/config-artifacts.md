# Config & artifacts: chezmoi mechanics, overlay, and delivery

How tracked files and agent artifacts are wired in this repo. Read this before
editing, then copy the closest existing entry. The chezmoi source root is `home/`
(`.chezmoiroot` points there), so a source path `home/dot_config/foo` materializes
to `~/.config/foo`.

## chezmoi entry types — pick by behavior

| You want… | Source naming | Example in repo |
|---|---|---|
| A plain managed file | `dot_<path>` | `dot_config/shell/env.sh` → `~/.config/shell/env.sh` |
| Per-OS / per-role values | add `.tmpl`, template off `.chezmoi.*` / data / switches | `dot_config/git/config.tmpl` |
| Append to a file you don't own | `modify_<file>` managed-block script | `modify_dot_bashrc`, `modify_dot_profile` |
| A live symlink into the overlay | `symlink_<name>.tmpl` (`stat`-guarded) | `dot_claude/symlink_settings.json.tmpl` |
| 0600 / private perms | `private_` name prefix | `dot_hermes/modify_private_auth.json` |
| Run logic at apply time | `run_onchange_*` / `run_after_*` script | `.chezmoiscripts/...` |

Notes:
- **`modify_` scripts** receive the current target file on stdin and print the new
  content. The idempotent pattern (strip any prior managed block, reappend a fresh
  one) is in `modify_dot_bashrc` — copy it; don't reinvent.
- **`.tmpl`** files render through Go templates. Available data: `.chezmoi.os` /
  `.chezmoi.arch`, the switches (`.clawbot`, `.gui`, `.install.*`), and anything in
  `.chezmoidata.yaml`. Test with `chezmoi execute-template < file`.

## The private overlay

`~/.dotfiles/private/` is a **separate git repo** cloned into a gitignored sibling
(not a submodule), holding **personal / non-public** content — *not* secrets. It may
be absent (it's cloned at provision only when a token was available). The clone token
is never written to its `.git/config`, but that does **not** make it read-only on a
clawbot: pushes authenticate through the gateway like any github.com repo, exactly as
they do for the public repo.

The public tree reaches into it via `symlink_*.tmpl` entries that emit a
`stat`-guarded absolute path, so the link **dangles silently** when the overlay is
absent and the public repo always stands alone:

```gotemplate
{{- $src := joinPath .chezmoi.sourceDir ".." "private" "home" "config" "claude" "settings.json" -}}
{{- if stat $src }}{{ $src }}{{ end -}}
```

Existing overlay symlinks: `~/.claude/settings.json`, opencode `AGENTS.md`,
Hermes `SOUL.md`, `~/.config/shell/env.local.sh`. `~/.claude/CLAUDE.md` is a tiny
*public* file that `@`-includes `AGENTS.md`.

**Contributing overlay content** works like the public repo (see SKILL.md Step 4):
branch + PR on the overlay repo, for humans and autonomous agents alike. If the
overlay clone is absent on a clawbot, clone it first (gateway-authenticated) and run
`chezmoi apply` once before branching. Real credentials never go in the overlay —
clawbots get *fake* seeded creds for gateway injection (see the seeders under
`dot_hermes/` and `dot_local/share/opencode/`).

## Verify delivery, not just the source

A successful source edit is not the finish line — confirm the **live target**
actually became the managed file/symlink after apply:

```bash
chezmoi apply ~/.config/<tool>           # or `--force` to overwrite a stray live file
readlink ~/.config/<tool>                # for overlay symlinks: should point at the source
stat -L ~/.config/<tool>/config.yaml     # exists, right perms, follows the link
```

**Pitfall — a stray hand-written live file blocks apply.** If `~/.config/<tool>`
already exists as a plain file/dir you (or someone) wrote by hand, chezmoi won't
silently clobber it. Decide deliberately: preserve, merge, or replace it with the
managed path (`chezmoi apply --force <target>` once you've confirmed it's safe to
overwrite). This is why writing the live file first is a trap.

## Gating

`home/.chezmoiignore.tmpl` lists paths *not* applied to a target:
- omitted entirely → applied on **every** box;
- under the `{{ if .clawbot }}` block → dropped on clawbots (personal / desktop
  layer);
- under `{{ if ne .chezmoi.os "darwin" }}` / `"linux"` blocks → dropped on the
  other OS;
- GUI-gated files (desktop apps/config) apply only where a display is detected.

Pick the bucket deliberately and justify it. If *you* (an agent on a clawbot) need
the file, it must **not** sit under the `{{ if .clawbot }}` block, or your box
won't receive it.

## Agent-artifact delivery (skills, AGENTS.md, context)

Delivery depends on the consuming agent's real load path — placing the source file
is not enough; confirm it actually loads.

- **Hermes** loads user skills from `~/.hermes/skills/` (categorized, e.g.
  `…/skills/devops/<name>/SKILL.md`). So a tracked file under
  `home/dot_hermes/skills/devops/<name>/SKILL.md` *is* the delivery — it
  materializes onto the load path, no symlink needed. (Hermes also seeds its own
  bundled skills there via `cp -rn` at install; coexist by using distinct names.)
- **Claude Code** reads `~/.claude/skills/` (personal) and `<project>/.claude/skills/`
  (project). The repo had **no** `~/.claude/skills` wiring historically — don't
  assume auto-delivery; add the link yourself.
- **Format:** both Hermes and Claude Code use `SKILL.md` with `name` + `description`
  frontmatter; Hermes additionally reads `metadata.hermes.*`, which Claude Code
  ignores. So one canonical `SKILL.md` can serve both via a superset frontmatter.

### How this very skill is delivered (the pattern to reuse)

This skill is the worked example of multi-consumer delivery:
- **Canonical** files live at `~/.dotfiles/ai/skills/<name>/` — at the repo root,
  *outside* `home/`, so chezmoi doesn't manage them; they're just real files present
  wherever the repo is cloned. Every skill (aws-sso, dotfiles-provisioning, …) lives
  here, so there's one home and one copy.
- **`.agents/` compat:** a committed relative symlink `.agents/skills/<name>` →
  `../../ai/skills/<name>`, so anything that scans the conventional `.agents/skills/`
  path (and the in-repo Claude Code link below) still resolves.
- **Claude Code (in-repo):** a committed relative symlink
  `.claude/skills/<name>` → `../../.agents/skills/<name>`, so Claude Code running
  inside `~/.dotfiles` picks it up as a project skill (resolves on through `.agents/`
  to `ai/`).
- **Hermes (any provisioned box):** a chezmoi symlink
  `home/dot_hermes/skills/devops/symlink_<name>.tmpl` that emits
  `{{ joinPath .chezmoi.sourceDir ".." "ai" "skills" <name> }}`, so on apply
  `~/.hermes/skills/devops/<name>` points at the canonical dir.

All of these are **directory** symlinks: the whole skill dir (SKILL.md plus any
scripts, references, evals) is delivered in one link — no per-file linking. Linking
each skill dir individually (rather than the whole skills folder) is deliberate: it
lets our skills coexist with Hermes' own seeded `devops` skills.

## macOS differences

On a human macOS box: tier-2 config arrives via `brew`; desktop apps/config are
GUI-gated; and the contribution path is normal PR + human review (no self-apply).
Keep these in mind so guidance degrades gracefully off the clawbot.
