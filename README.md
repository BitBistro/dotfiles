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

Machine-specific values (git identity, GPG key, backup repo) live in
`~/.env-local` -- see [Machine identity](#machine-identity) below.

## Machine identity

Machine-specific values live in `~/.env-local`, sourced by `~/.bashrc` for
every interactive shell. On first run `scripts/01-init-env-local.sh`
prompts for the `GIT_*` values and appends them to the file.

A typical `~/.env-local`:

```sh
export GIT_USER_NAME="Jane Doe"
export GIT_USER_EMAIL="jane@example.com"
export GIT_SIGNINGKEY="4F3A8B1D2C9E5F70A6B8D3E1C4F9A2B5D8E1C7F3"
export RESTIC_REPOSITORY="/home/jane/OneDrive/Backup/WSL"
```

The `GIT_*` vars feed `scripts/10-git-config.sh`, which writes your global
gitconfig. `RESTIC_REPOSITORY` is read at runtime by the `backup` tool
installed under `~/.local/bin/`.

To update identity variables later, edit `~/.env-local` directly (or delete
the relevant `export` lines and re-run the pipeline).

## Repo layout

| Path | Purpose |
|------|---------|
| `bin/` | Entry-point scripts you run by hand: the pipeline dispatcher (`run-scripts.sh`) and the Debian package installer (`add-deb-packages.sh`). |
| `scripts/` | Numbered stages run by `bin/run-scripts.sh` in lexical order (see below). |
| `overlays/` | Dotfiles rsynced into `$HOME` by `50-copyfiles.sh`. `base/` is always applied; OS-specific subdirs (e.g. `darwin/`) are layered on top. |
| `tools/` | Vendored helper scripts installed to `~/.local/bin` by `scripts/09-install-tools.sh`: `backup`, `browser`, `keys`, `pinentry`. `tools/systemd/` holds the unit and D-Bus activation templates for `pass-secret-service`. |
| `attic/` | Archived one-off scripts kept for reference. Not used by the pipeline. |

## How it works

`bin/run-scripts.sh` detects the OS and runs every `scripts/NN-name.sh` in
lexical order, passing `BASEDIR`, `OSENV` (`linux`|`darwin`), and `FLAVOR`
(distro, e.g. `ubuntu`) to each script. A script returning a non-zero exit
code halts the pipeline.

### Script stages

| Range | Purpose |
|-------|---------|
| `00-09` | Init -- create dirs, seed empty config files, prompt for machine identity (`~/.env-local`), install user-local tools (`backup`, `browser`, `keys`, `pinentry`) |
| `10-19` | Core config -- git, GPG agent, SSH, pinentry registration |
| `20-29` | OS tweaks -- remove snap (Ubuntu), fix macOS fonts |
| `50-59` | Copy dotfiles from `overlays/` to `$HOME`; install language runtimes and tools (Go, Helm, Terraform, uv, frogmouth, mcp-proxy, pass-secret-service) |
| `99` | Cleanup and permission fixes |

Notable scripts:

| Script | What it does |
|--------|-------------|
| `00-init.sh` | Creates standard dirs with mode 700 (`~/.ssh`, `~/.gnupg`, `~/.password-store`, etc.) |
| `01-init-env-local.sh` | Interactively prompts for `GIT_*` vars and writes `~/.env-local` |
| `09-install-tools.sh` | Installs `backup`, `browser`, `keys`, `pinentry` to `~/.local/bin`; on WSL registers a passthrough browser desktop entry |
| `10-git-config.sh` | Writes global gitconfig non-destructively (guarded by `--get` checks); reads identity from `~/.env-local` |
| `10-gnupg-config.sh` | Idempotently sets GPG agent config values and enables SSH support |
| `10-ssh-config.sh` | Appends `ServerAliveInterval`, `VisualHostKey`, and GPG `UPDATESTARTUPTTY` to `~/.ssh/config` if not already present |
| `11-pinentry-register.sh` | Writes `pinentry-program` into `gpg-agent.conf`; kills the running agent so the change takes effect |
| `51-pass-secret-service.sh` | Downloads and verifies the `pass-secret-service` binary from GitHub releases |
| `52-pass-secret-service-setup.sh` | Initializes the pass store (if needed), installs systemd user unit and D-Bus activation file, and enables the service |

## Dotfile overlays

Files under `overlays/base/` are rsynced to `$HOME` by `50-copyfiles.sh`.
OS-specific files live under `overlays/darwin/` etc. and are layered on top.

To skip the copy step (e.g. you have made local edits you do not want
overwritten), create `~/.skip_copy_files`. Delete it when you want updates
to flow through again.

Note: `overlays/base/.skip_copy_files` is itself part of the overlay, so a
fresh install will create the opt-out file automatically after the first
successful rsync.

## Package installation

Primary target is Debian (bare metal and under WSL). `bin/add-deb-packages.sh`
is actively maintained and takes a level argument (`base`, `standard`,
`extra`, `audit`, `cleanup`, `zfs`, `kvm`):

```sh
bin/add-deb-packages.sh extra
```
This script is not called by the main pipeline; invoke it manually.
