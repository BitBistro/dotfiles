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

The pipeline reads machine-specific values (git identity, GPG key, backup
repo) from environment variables. On the very first run those don't exist
yet — see [Machine identity](#machine-identity) below for the bootstrap
flow.

## Machine identity

Machine-specific values live in `~/.env-local` and are pulled into the
environment by `~/.bashrc` for every interactive shell. The pipeline
expects them already exported in the shell that invokes
`bin/run-scripts.sh`; nothing in `scripts/` re-sources the file.

A typical `~/.env-local`:

```sh
export GIT_USER_NAME="Jane Doe"
export GIT_USER_EMAIL="jane@example.com"
export GIT_SIGNINGKEY="4F3A8B1D2C9E5F70A6B8D3E1C4F9A2B5D8E1C7F3"
export RESTIC_REPOSITORY="/home/jane/OneDrive/Backup/WSL"
```

The `GIT_*` vars are consumed by `scripts/10-git-config.sh` to write your
global gitconfig. `RESTIC_REPOSITORY` is read at runtime by the `backup`
tool installed under `~/.local/bin/`.

**First run:** the file doesn't exist yet, so `scripts/01-init-env-local.sh`
prompts for the `GIT_*` values mid-pipeline and appends them. Those vars
won't be visible to `10-git-config.sh` in the same run — start a new shell
(or `. ~/.env-local`) and re-run `bin/run-scripts.sh` so the git settings
actually apply. Add `RESTIC_REPOSITORY` by hand.

To update identity variables later, edit `~/.env-local` directly (or delete
the relevant `export` lines and re-run the pipeline) and start a fresh
shell.

## Repo layout

| Path | Purpose |
|------|---------|
| `bin/` | Entry-point scripts you run by hand: the pipeline dispatcher (`run-scripts.sh`) and the `add-*-packages.sh` package lists. |
| `scripts/` | Numbered stages run by `bin/run-scripts.sh` in lexical order (see below). |
| `overlays/` | Dotfiles rsynced into `$HOME` by `50-copyfiles.sh`. `base/` is always applied; OS-specific subdirs (e.g. `darwin/`) are layered on top. |
| `tools/` | Vendored helper scripts (`backup`, `pinentry`, `browser` + desktop template) installed to `~/.local/bin` by `scripts/09-install-tools.sh`. |
| `attic/` | Archived one-off scripts kept for reference. Not used by the pipeline. |

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

## Dotfile overlays

Files under `overlays/base/` are rsynced to `$HOME` by `50-copyfiles.sh`.
OS-specific files live under `overlays/darwin/` etc. and are layered on top.

To skip the copy step (e.g. you've made local edits you don't want
overwritten), create `~/.skip_copy_files`. Delete it when you want updates
to flow through again.

## Package installation

Primary target is Debian (bare metal and under WSL). `bin/add-deb-packages.sh`
is actively maintained and takes a level argument (`base`, `standard`,
`extra`, `desktop`, `cleanup`, `zfs`, `kvm`):

```sh
bin/add-deb-packages.sh extra
```

`bin/add-ubuntu-packages.sh`, `bin/add-mint-packages.sh`, and
`bin/add-mac-packages.sh` exist for occasional use but lag the Debian list —
treat them as starting points, not canonical.

These scripts are not called by the main pipeline; invoke them manually.
