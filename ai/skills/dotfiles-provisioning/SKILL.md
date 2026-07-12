---
name: dotfiles-provisioning
description: >-
  How to add or change anything provisioned by the chezmoi dotfiles repo at
  ~/.dotfiles — a CLI tool/binary, a managed config file, or an agent artifact
  (a skill, AGENTS.md, CLAUDE.md, agent context). Use this whenever you need a
  command-line tool that isn't on PATH, want to install/provision something so it
  persists across machines, or are adding/editing a tracked dotfile, template,
  symlink, or agent skill. Trigger it even when the user just says "I need <tool>",
  "install X", "set this up on my machine", "add this to my dotfiles", or "make a
  skill/agent config" — anything that should be reproducible via provisioning
  rather than a throwaway local edit. This applies to a single config file too:
  "provision / set up / persist the config for <tool>" (e.g.
  ~/.config/<tool>/config.yaml, ~/.aws/config) means route it through the repo —
  do NOT just hand-write the live file, even though that seems like the quick path.
metadata:
  hermes:
    tags: [provisioning, chezmoi, dotfiles, install, tool, package, runtime, mise, config, skill, gating]
    related_skills: []
---

# Dotfiles provisioning

This repo (`~/.dotfiles`, managed by [chezmoi](https://www.chezmoi.io/)) provisions
both human macOS machines and headless Linux agent boxes ("clawbots"). Use this
skill to decide the *right* way to bring a tool, config file, or agent artifact
onto a machine — and, when it should persist, to contribute it back to the repo
so every future provision gets it.

The throughline: **prefer the least-invasive, most-reproducible option, and make
durable changes through the repo, not by hand.** An ad-hoc install or edit
evaporates on the next box; the repo is the durable path.

## Step 1 — Know your situation

Two things shape every later decision. Figure them out first:

**What am I running as?** This decides how a change gets contributed (Step 4):
- **Autonomous agent on a clawbot** (headless Linux, you have root, you run behind
  an egress gateway, no human is reviewing in real time). You can `apply` your own
  branch to unblock immediately, but durable changes still go through review.
- **Working alongside a human** (e.g. Claude Code on the user's macOS box). A human
  can review and merge — open a normal PR and let them.

If unsure: are you on a headless box with no interactive user? Then assume the
clawbot path. `uname` and `$DISPLAY` are good signals.

**What am I adding?** This picks the decision ladder:
- A **CLI tool / binary** → the **acquisition ladder** below.
- A **config file or agent artifact** (dotfile, template, symlink, skill,
  `AGENTS.md`, context) → the **placement ladder** below.

**Don't assume a capability is missing just because you don't see it in-session.**
On a clawbot the environment wires up things that aren't visible to you — GitHub
push/PR access, Telegram, and similar all "just work" via the gateway. Before you
skip a step or report a blocker, **verify or actually attempt it**; treat "I don't
see it" as "check," not "it's not there."

## Step 2 — Acquisition ladder (tools)

Walk these rungs in order; stop at the first that fits. Detailed tier mechanics,
the exact files to edit, and worked examples are in
[references/tools.md](references/tools.md) — read it before editing the repo.

0. **Needed at all?** One-shot/throwaway task → **install nothing**, run it
   ephemerally: `uvx <pkg>` (Python), `npx`/`bunx` (Node), `docker run --rm <image>`
   if Docker is available, or download to a temp dir and discard. Persisting a tool
   is a deliberate choice.
1. **A language runtime/toolchain?** (Node, JVM/Java, Python, …) → use the version
   manager, never add a runtime to the repo: Python → `uv`; Node/JVM/Java and
   anything `mise` manages → `mise use -g <tool>@<ver>`.
2. **A persistent CLI tool → add it to the repo**, choosing the tier by how the
   tool ships, in the repo's defined order (tier 3 is the fallback when no package
   exists); favor a single static binary, avoid root:
   - **Tier 1 — release binary (preferred):** static binary published for Linux +
     macOS arches → `~/.local/bin`, no root. Edit `.chezmoidata.yaml`,
     `shared.yaml.tmpl`, and the `archiveName*` matrix.
   - **Tier 2 — package manager:** macOS `brew`, Linux `apt`. Preferred over a
     bespoke installer when a clean package exists.
   - **Tier 3 — vendor installer:** an official sudo-free install into a user
     prefix, when neither of the above fits.
   - **Root/system install — last resort**, justified. **Never assume you have
     root.** Any script that touches the system must use `sudo` *only when needed
     and only when it's passwordless* — the `id -u` / `sudo -n` guard idiom every
     apt script here already uses (see [references/tools.md](references/tools.md)).
     If the box has neither root nor passwordless sudo, **do not try to force the
     install** — an interactive password prompt has no human on a clawbot. Open the
     PR and ask the owner to run `chezmoi apply` (or the privileged step)
     themselves; see Step 4.

## Step 2′ — Placement ladder (config & artifacts)

Walk these rungs in order; stop at the first that fits. The chezmoi entry-type
mechanics, examples, and artifact-delivery specifics are in
[references/config-artifacts.md](references/config-artifacts.md) — read it before
editing the repo.

0. **Track it at all — and don't write the live file first.** A genuine one-off
   tweak you don't need reproduced → write it live, but *say* it isn't provisioned.
   But if the user said **provision / set up / persist** (or it should survive
   re-provisioning), do **not** hand-write `~/.config/...`, `~/.aws/...`, etc. —
   that's the trap: a live file written by hand isn't provisioned and can later
   *block* `chezmoi apply`. Create the chezmoi source entry, then `chezmoi apply`.
   **Already wrote it live?** Repair it: replace the live file with the managed
   source (or move the content into the overlay), re-apply, and say you corrected it.
1. **Personal / non-public / machine-specific?** (NOT secrets) → it belongs in the
   **private overlay** (`~/.dotfiles/private/`, a *separate* repo), surfaced via a
   `stat`-guarded `symlink_<name>.tmpl`. Contribute its content the same way as the
   public repo — branch + PR on the overlay repo (Step 4) — for humans and autonomous
   agents alike.
2. **Otherwise pick the chezmoi entry type by behavior:** plain file → `dot_<path>`;
   needs per-OS/role values → add `.tmpl`; must append to a file you don't own
   (`.bashrc`) → a `modify_` managed-block script; live overlay symlink →
   `symlink_<name>.tmpl`; 0600 perms → `private_` prefix.
3. **Agent artifacts (skills, `AGENTS.md`, `CLAUDE.md`, context):** delivery depends
   on the consumer — Hermes loads skills from `~/.hermes/skills/` (placement under
   `dot_hermes/skills/...` *is* delivery); Claude Code reads `~/.claude/skills/`.
   Placing the file is not enough — confirm it lands on the consumer's real load
   path and actually loads. See the reference.

## Step 3 — Gating: who should receive it?

Whatever you add, decide which machines get it, and **justify the choice** (in the
PR, or to the user). The levers differ by what you're adding:
- **Tools:** the "always/minimal" set (every box), `{{ if not .clawbot }}`
  (personal only — a clawbot won't get it), or a new `INSTALL_*` switch (opt-in).
- **Config/artifacts:** `home/.chezmoiignore.tmpl` (omit = everywhere; under the
  `{{ if .clawbot }}` block = dropped on clawbots; per-OS blocks; GUI-gated).

If *you* (an agent) need it now, make sure it lands somewhere your machine receives.

## Step 4 — Contribute it back

First decide **which repo the change targets**. An overlay-backed file is often
*two* changes in *two* repos: the public `symlink_*.tmpl` stub **and** the private
content.

- **Public repo** (`~/.dotfiles`): branch and open a PR.
- **Private overlay** (`~/.dotfiles/private/`): a separate GitHub repo, contributed
  to **exactly like the public repo** — branch + PR. On a clawbot the gateway
  authenticates push/PR for *any* github.com repo (the overlay's origin is a plain
  https URL with no embedded token), so "the clone token isn't persisted" does **not**
  mean you can't push — auth simply comes from the gateway at push time, same as the
  public repo. See "Private overlay" below for the two wrinkles.

### Public repo

1. **Branch** off `main`: `gh-<xxx>-<short-desc>` (e.g. `gh-42-add-ripgrep`), where
   `<xxx>` is the issue number, or `0` if none. Make the edits.
2. **Verify before sharing** (mandatory floor, then best-effort):
   - `chezmoi apply` succeeds with **no template errors**, and the change actually
     landed — a tool is on PATH and runs (`<tool> --version`); a file materializes
     at its target; a `symlink_*` resolves (or dangles by design); a `modify_`
     block is present and idempotent (apply twice, no drift).
   - `shellcheck` any new/edited script; sanity-check templates with
     `chezmoi execute-template`.
   - Run `test/run.sh verify` **if Docker is available**; if not, say so explicitly.
3. **Commit + PR** against `main`, `GH-<xxx>` convention: commit `GH-<xxx> <msg>`,
   PR title `GH-<xxx> <title>`.
   - *(autonomous agent)* **GitHub just works on a clawbot** — `git push` and
     `gh pr create` are authenticated out of the box (gateway-handled). Just push
     and open the PR; don't treat a GitHub auth message as a blocker.
4. **Then, depending on your situation:**
   - **Human in the loop** (your mac): you're done — the human reviews and merges.
     No self-apply needed; `chezmoi apply` on `main` after merge.
   - **Autonomous agent — decide by recoverability.** If the change is low-risk and
     easily reversible, `chezmoi apply` from your branch to go live now, and notify
     the owner async (e.g. send the PR link over Telegram) for unblocking review. If
     it's risky, irreversible, or hard to recover from, **don't self-apply** — send
     the PR over Telegram and wait for confirmation before applying. When in doubt,
     wait.
   - **Needs root you don't have?** A privileged (root/system) install can only be
     self-applied where you have root or *passwordless* sudo. If the box has
     neither, you **can't** apply it — don't attempt to force it. Push the PR and
     ask the owner to run `chezmoi apply` (or the privileged step) themselves, same
     as the "wait" path above.
   - **Telegram works the same way — don't assume it's unavailable.** Not seeing it
     in your session is *not* evidence it's missing; on a clawbot it's typically
     wired up and can send. **Actually attempt the send** (or verify the channel)
     before concluding you can't reach the owner — only fall back to email if the
     send truly fails, and never silently skip notifying. (Same principle as GitHub
     above: don't treat "I don't see it" as "it's not there.")
   - **While parked on an unmerged branch** (you applied from it): your working tree
     *is* that branch. **Don't switch branches yet** — that reverts the applied
     change — and `chezmoi apply` / auto-`update` runs *on this branch*, so it won't
     see other merges to `main`. So don't open a *second, unrelated* PR while parked;
     if a further change is related, push it to the **same** branch/PR. Leave a
     visible marker that the box is parked on `<branch>` pending PR `#<n>`.
   - **Once the PR merges: reconcile yourself.** Watch for the merge and, when you
     see it, switch back to `main` and pull — without waiting to be told. It's safe
     now (your change is in `main`), and the pull also brings in any other merges you
     were missing while parked.

### Private overlay

The overlay is a separate GitHub repo, so contribute to it the **same way as the
public repo** — branch off its `main`, push, and open a PR — using the same
gateway-authenticated `git`/`gh` that work for the public repo. The self-apply
decision is identical too: park on your branch by recoverability, notify the owner,
reconcile to `main` after merge. Two wrinkles are specific to the overlay:

1. **It may not be present.** On a clawbot the overlay is cloned at provision only
   when a token was available, so `~/.dotfiles/private/` can be absent. If it is,
   **clone it first** — the gateway authenticates the clone like any github.com repo;
   its URL mirrors the public repo's origin with a leading dot on the repo name
   (`https://<host>/<owner>/.<repo>.git`). Then run **`chezmoi apply` once** so the
   overlay symlinks resolve and everything refreshes. Now branch + PR as above.
2. **It's a second repo.** An overlay-backed change is usually *two* PRs — the public
   `symlink_*.tmpl` stub in `~/.dotfiles` and the content in `~/.dotfiles/private`.
   Land and track both.

## Hard rules

- **No secrets, ever.** Real credentials/tokens go in *no* repo — neither the
  public repo nor the private overlay is for secrets.
- **Reference private/personal things abstractly**, never by real value — this
  skill and the public repo are public.
- **The repo must stand alone.** Overlay symlinks dangle silently when the overlay
  is absent; never make the public tree depend on private content existing.

## References

- [references/tools.md](references/tools.md) — tier mechanics, the exact files to
  edit for each tier, and worked examples (`rg`, `aws-cli`).
- [references/config-artifacts.md](references/config-artifacts.md) — chezmoi
  entry-type mechanics with examples, the private-overlay model, and agent-artifact
  delivery (Hermes vs Claude Code).
