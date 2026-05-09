# dotfiles

Personal dotfiles and system setup scripts for Linux (Debian/Ubuntu/Mint) and macOS.

## Bootstrap

```sh
git clone git@github.com:BitBistro/dotfiles.git ~/C/dev/dotfiles
cd ~/C/dev/dotfiles
bin/run-scripts.sh
```

Pass `-y` to skip all confirmation prompts (non-interactive/CI use):

```sh
bin/run-scripts.sh -y
```

## How it works

`bin/run-scripts.sh` detects the OS and runs every `scripts/NN-name.sh` in
lexical order, passing `BASEDIR`, `OSENV` (`linux`|`darwin`), and `FLAVOR`
(distro, e.g. `ubuntu`) to each script. A script returning exit code 255
halts the pipeline.

### Script stages

| Range | Purpose |
|-------|---------|
| `00-09` | Init — create dirs, seed empty config files |
| `01` | Prompt for machine identity (`~/.env-local`) |
| `09` | Install user-local tools (`backup`, `pinentry`; `browser` + desktop entry on WSL) |
| `10-19` | Core config — git, SSH, GPG |
| `20-29` | OS tweaks — remove snap, fix macOS fonts |
| `50-59` | Copy dotfiles from `overlays/` → `$HOME`; install tools (Go, Helm, Terraform) |
| `99` | Cleanup and permission fixes |

### Machine identity

`scripts/01-init-env-local.sh` prompts for git identity and GPG key on first
run and appends them to `~/.env-local`. This file is sourced by:

- `~/.bashrc` (interactive shells only)
- `scripts/10-git-config.sh` (at install time)

To update identity variables, edit `~/.env-local` directly or delete the
relevant `export` lines and re-run `bin/run-scripts.sh`.

## Dotfile overlays

Files under `overlays/base/` are rsynced to `$HOME` by `50-copyfiles.sh`.
OS-specific files live under `overlays/darwin/` etc. and are layered on top.

To skip the copy step (e.g. you've made local edits you don't want
overwritten), create `~/.skip_copy_files`. Delete it when you want updates
to flow through again.

## Package installation

Package lists live in `bin/add-*-packages.sh`. They are not called by the
main pipeline — invoke them manually as needed:

```sh
bin/add-ubuntu-packages.sh standard
bin/add-mac-packages.sh
```
