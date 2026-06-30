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

## Am I already authenticated?

```bash
aws-sso-auto list AccountName RoleName Profile Expires --csv
```

Shows the roles you can assume and when each cached credential expires. If the
profile you need is still valid, skip login.

## Log in (one human approval per session)

The agent has no browser, so login uses the device-code flow:

```bash
aws-sso-auto login --url-action printurl
```

It prints a URL and a verification code. Hand both to the human and wait for them to
approve in their browser. If you retried, only the code from the **currently
running** login process is valid. After approval, AWS CLI calls refresh credentials
automatically for the rest of the session.

## Run AWS CLI commands

Profiles live in `~/.aws/config`; pick one with `AWS_PROFILE` and let
`credential_process` handle the refresh:

```bash
AWS_PROFILE='<Account>:<Role>' aws sts get-caller-identity
AWS_PROFILE='<Account>:<Role>' aws s3 ls
```

First time on a fresh box (or if a profile is missing), regenerate them once:
`aws-sso-auto setup profiles --force`.

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
