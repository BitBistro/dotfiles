# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles + system bootstrap scripts for Linux (Debian/Ubuntu/Mint) and macOS. There is no build, no tests, no linter — every change is a shell script or a dotfile that runs on a user machine.

## Common commands

```sh
bin/run-scripts.sh        # interactive: confirms before running pipeline
bin/run-scripts.sh -y     # non-interactive (also skips the rsync confirmation in 50-copyfiles.sh via WITH_FORCE=true)
bin/add-deb-packages.sh <level>   # apt installs; LEVEL ∈ base|standard|extra|desktop|cleanup|zfs|kvm. Not invoked by the pipeline.
```

The `add-ubuntu-packages.sh`, `add-mint-packages.sh`, `add-mac-packages.sh` lists exist but lag behind `add-deb-packages.sh` — treat them as starting points.

To run a single pipeline stage directly while iterating:

```sh
bash scripts/09-install-tools.sh "$PWD" linux ubuntu
```

The three positional args are `BASEDIR OSENV FLAVOR` — `run-scripts.sh` always passes them, so scripts can assume `$1/$2/$3`.

## Pipeline architecture

`bin/run-scripts.sh` is the dispatcher. It:

1. Detects `OSENV` (`linux`|`darwin`) from `uname` and `FLAVOR` (e.g. `ubuntu`, `debian`) from `lsb_release`.
2. Globs `scripts/NN-name.sh` (regex `[0-9][0-9][a-zA-Z-]+\.sh`), sorts lexically, runs each as `bash SCRIPT "$BASEDIR" "$OSENV" "$FLAVOR"`.
3. **Exit code 255 halts the pipeline**; any other non-zero exit is ignored and the next script runs. Use 255 only for unrecoverable preconditions (missing required dep, etc.).

Stage ranges (the number is load-bearing — it controls order):

| Range | Purpose |
|-------|---------|
| `00-09` | Init: dirs, seed `~/.env-local`, install user-local tools (`backup`, `pinentry`, WSL `browser`) |
| `10-19` | Core config: git, GPG, SSH, pinentry registration |
| `20-29` | OS tweaks: snap removal (linux), font fixes (darwin) |
| `50-59` | rsync overlays → `$HOME`; install Go/Helm/Terraform |
| `99`    | Cleanup + permission fixes on `~/.ssh`, `~/.gnupg` |

When adding a new step, pick a stage that matches its dependencies (e.g. anything touching `~/.gnupg` must come after `10-gnupg-config.sh`).

## Overlays

`scripts/50-copyfiles.sh` rsyncs `overlays/base/` → `$HOME`, then layers `overlays/$OSENV/` on top (`overlays/darwin/` exists; `overlays/linux/` does not). Quirks:

- `~/.skip_copy_files` short-circuits the whole script. **`overlays/base/.skip_copy_files` is itself in the overlay**, so a fresh install creates the opt-out file after the first successful copy — subsequent runs become no-ops unless the user deletes it.
- Without `-y`, the script first does a dry-run preview and prompts before applying.

New dotfiles always go under `overlays/base/` (or `overlays/darwin/` for macOS-only).

## Machine identity

Machine-specific values live in `~/.env-local` (not in this repo). Sourced by `overlays/base/.bashrc` for interactive shells, and read by `scripts/10-git-config.sh` at install time. `scripts/01-init-env-local.sh` prompts for `GIT_USER_NAME`, `GIT_USER_EMAIL`, `GIT_SIGNINGKEY` on first run and appends them.

`scripts/10-git-config.sh` uses `git config --get` before each `--global` set, so it never overwrites existing user config.

## Tools directory

`tools/bin/{backup,browser,pinentry}` and `tools/share/applications/browser.desktop.in` are vendored helpers installed by `scripts/09-install-tools.sh` into `~/.local/bin/` and `~/.local/share/applications/`. The `browser` tool and its `.desktop` entry are WSL-only; the script's WSL block detects WSL via `/proc/version` + `wslpath` and checks for drift before re-rendering the `.desktop` file, refreshing the MIME cache, or calling `xdg-settings`.

## Conventions for new scripts

- Idempotent: detect current state and skip work when already applied. See the WSL block in `scripts/09-install-tools.sh` — note it checks only the `Exec=` line of `browser.desktop`, not the whole file, because `xdg-settings` mutates `MimeType` after registration; a full-file compare would loop. Same script invokes `xdg-settings` with `XDG_CURRENT_DESKTOP=X-Generic BROWSER=""` for both `get` and `set` so they share a code path.
- Use exit `255` only when continuing would corrupt later stages; otherwise let the pipeline continue.
- `WITH_FORCE=true` in the environment means non-interactive mode — don't prompt.
