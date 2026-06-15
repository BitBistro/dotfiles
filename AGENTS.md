# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

See `README.md` for bootstrap, repo layout, stage ranges, machine-identity flow, overlay basics, and package install. This file only covers what's not there.

## Running a single stage

The pipeline dispatcher passes `BASEDIR OSENV FLAVOR` to every script. To iterate on one stage directly:

```sh
bash scripts/09-install-tools.sh "$PWD" linux ubuntu
```

## Pipeline exit-code contract

`bin/run-scripts.sh` treats **any non-zero exit code as fatal** (pipeline halts). Ensure scripts exit non-zero only when they have failed and cannot safely proceed.

## Non-obvious behavior

- **`~/.skip_copy_files` self-disable**: `overlays/base/.skip_copy_files` is itself in the overlay, so a fresh install creates the opt-out file after the first successful rsync. Subsequent `50-copyfiles.sh` runs become no-ops unless the user deletes it.
- **`10-git-config.sh` is non-destructive**: every `--global` set is guarded by a `--get` check, so adding new keys to that script won't overwrite values the user has already configured. It also sources `~/.env-local` at runtime to pick up `GIT_*` vars when they are not already in the environment (covers first-run before the parent shell has loaded them).
- **`WITH_FORCE=true`** in the env means non-interactive mode. `run-scripts.sh -y` exports it, and `50-copyfiles.sh` checks it to skip its rsync preview/confirm prompt. New scripts that prompt should honor it.
- **`pass` store idempotency**: `52-pass-secret-service-setup.sh` checks `~/.password-store/.gpg-id` before running `pass init`. If the file already contains the signing key (case-insensitive match), init is skipped. This prevents re-encrypting an existing store on re-runs.

## WSL browser-install idempotency (scripts/09-install-tools.sh)

Two gotchas learned the hard way:

- Compare only the `Exec=` line of `browser.desktop`, not the whole file. `xdg-settings` mutates `MimeType` after registration (adds `x-scheme-handler/unknown`), so a full-file compare detects drift on every run and triggers a rewrite loop.
- Invoke `xdg-settings` with `XDG_CURRENT_DESKTOP=X-Generic BROWSER=""` for **both** `get` and `set`. Without it, `get` returns empty and the comparison always fails, so `set` runs unconditionally. `DE=generic` (the older form) is not equivalent.

## Conventions for new scripts

- Idempotent: detect current state and skip work when already applied.
- Pick the right stage number (see README "Script stages" table) -- the number controls order and load-bearing dependencies between stages.
- Don't push to `~/` directly; add to `overlays/base/` (or `overlays/$OSENV/`) and let `50-copyfiles.sh` sync.
- Every script must have a `#!/bin/bash` (or `#!/bin/sh`) shebang -- shellcheck enforces this (SC2148).
- Pipeline args (`BASEDIR`, `OSENV`, `FLAVOR`) that are not used by a script should be commented out rather than left as live assignments to avoid SC2034.
- All scripts must pass `shellcheck` with zero warnings before committing.

