# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Layout: multi-context, no central map

This working tree is a superproject of independent submodules, each its own git
repo. **There is no root `CONTEXT-MAP.md`.** Instead, each submodule/repo carries
its own `CONTEXT.md` (and optional `docs/adr/`) at *its* root:

```
/
├── CONTEXT.md                         ← root dotfiles context
├── docs/adr/                          ← root-level decisions
├── clawtilla/
│   ├── CONTEXT.md
│   └── docs/adr/
├── private/
│   ├── CONTEXT.md
│   └── docs/adr/
└── private/clawtilla/
    ├── private/CONTEXT.md
    └── clawpatrol/CONTEXT.md
```

## Before exploring, read these

Work out which submodule you're touching, then read the domain docs at *that*
submodule's root:

- **`CONTEXT.md`** at the relevant submodule root (fall back to the repo-root `CONTEXT.md` for cross-cutting work).
- **`docs/adr/`** at that submodule root — read ADRs that touch the area you're about to work in.

If any of these files don't exist, **proceed silently**. Don't flag their
absence; don't suggest creating them upfront. The `/domain-modeling` skill
(reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates
them lazily when terms or decisions actually get resolved.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in the relevant `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
