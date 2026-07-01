---
name: aws-sso
description: Use when an agent on a clawbot/headless box needs to authenticate to AWS and run AWS CLI commands (via aws-sso-cli / IAM Identity Center), or to troubleshoot AWS SSO auth failures. The install and config are provisioned by dotfiles; this covers logging in and using it.
version: 1.0.0
author: clawbot
metadata:
  hermes:
    tags: [aws, aws-cli, aws-sso, clawbot, credential-process]
    related_skills: [dotfiles-provisioning]
---

# Using AWS SSO on a clawbot

`aws-sso-cli` is already installed and configured on this box (provisioned via
dotfiles — if the setup itself needs changing, that's `dotfiles-provisioning`'s
job, not this skill). Always drive it through the **`aws-sso-auto`** wrapper: it
supplies the secure-store password and config path non-interactively, so login and
credential refresh work without prompts.

## Run AWS CLI commands

Profiles live in `~/.aws/config`; pick one with `AWS_PROFILE` and let
`credential_process` handle the refresh:

```bash
AWS_PROFILE='<Account>:<Role>' aws sts get-caller-identity
AWS_PROFILE='<Account>:<Role>' aws s3 ls
```

Each profile's `credential_process` re-mints short-lived STS role credentials
**automatically and non-interactively** on every `aws` call, so you don't manage
or refresh credentials by hand — just run the command you wanted.

First time on a fresh box (or if a profile is missing), regenerate them once:
`aws-sso-auto setup profiles --force`.

## Am I already authenticated?

Don't guess from cached state — **just run the command.** Because
`credential_process` refreshes STS creds transparently, the only reliable check is
a real call:

```bash
AWS_PROFILE='<Account>:<Role>' aws sts get-caller-identity
```

If it succeeds, you're authenticated. `aws-sso-auto list AccountName RoleName
Profile Expires --csv` is purely **informational** — it shows when each *cached*
STS credential lapses. `Expired` there means only that the cache is stale; the next
`aws` call re-mints it for you. It does **not** mean you're logged out, and it is
**not** a signal to log in.

## When do I actually need to log in?

Two different credential lifetimes are in play — don't conflate them:

- **STS role credentials** — short-lived, per-profile. This is what
  `aws-sso-auto list … Expires` displays and what `credential_process` refreshes
  automatically on the next `aws` call. Expiry here needs **no action**.
  (`aws-sso-auto … --sts-refresh` forces an immediate refresh, but that's normally
  unnecessary.)
- **SSO session** — long-lived (hours, per the IdP session). Created by the
  device-code login flow, and the **only** thing that requires human browser
  approval.

**Rule:** never run `login` because `list` shows `Expired`. Log in only when an
actual `aws` call **fails** with an error saying the SSO session/token is expired
or missing (reauthentication required).

## Log in — fallback when the SSO session has expired

Reach for this only after a real `aws` call fails for the reason above. The agent
has no browser, so login uses the device-code flow:

```bash
aws-sso-auto login --url-action printurl
```

It prints a URL and a verification code. Hand both to the human and wait for them to
approve in their browser. If you retried, only the code from the **currently
running** login process is valid. After approval, AWS CLI calls refresh credentials
automatically for the rest of the session.

**Identity guard (automatic).** This box has its own dedicated SSO user. The human
approving the device link must be signed into AWS SSO **as that bot user**, not as
themselves — otherwise the token binds to *their* identity and this box inherits it.
To catch that, `aws-sso-auto login` verifies, right after login, that every role the
authenticated user can reach is within the bot's allowlist (the `Accounts`/`Roles`
block in `~/.config/aws-sso/config.yaml`). If it isn't, login **fails**:

```
aws-sso-auto: SSO identity mismatch — the authenticated user can access role(s)
  outside this bot's allowlist: ...
```

That message means the wrong SSO user approved the link. Do **not** work around it
(don't call bare `aws-sso login`, don't edit the allowlist to admit the extra roles).
Ask the human to approve again signed in as the **bot's** SSO user, then re-run
`aws-sso-auto login`. The guard is skipped only when no allowlist is declared (e.g. a
personal box); on this box it is expected to be enforced.

## Never leak secrets

Do not print or echo `AWS_SSO_FILE_PASSWORD`, the password file, credential-process
JSON from `aws-sso process`, or STS `AccessKeyId`/`SecretAccessKey`/`SessionToken`.
Verify access with `aws sts get-caller-identity`, never `aws-sso process`. If
credentials do land in output, say so without repeating them and run
`aws-sso-auto logout` to invalidate them.

## Troubleshooting

- **`inappropriate ioctl for device` on login** — the secure-store password isn't
  available. Confirm `~/.config/aws-sso/file-password` exists (mode 0600) or
  `AWS_SSO_FILE_PASSWORD` is set; the wrapper reads either.
- **A profile's `aws` calls fail but the wrapper works** — the profile's
  `credential_process` must invoke `aws-sso-auto`, not bare `aws-sso`. Regenerate
  with `aws-sso-auto setup profiles --force`.
- **PKCE / browser errors** — a headless box can't use PKCE or `open` URL actions;
  the provisioned config already uses `device_code` + `printurl`. Read
  `~/.config/aws-sso/config.yaml` to see the active settings.
