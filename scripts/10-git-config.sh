if ! command -v git >/dev/null 2>&1; then
    echo "Git not installed... bailing"
    exit 255;
fi

# Pull machine-specific secrets/overrides (e.g. GIT_SIGNINGKEY) from ~/.env-local
# if present. .env-local is created by 00-init.sh as an empty file; users add
# any of the GIT_* variables consumed below.
[ -r "$HOME/.env-local" ] && . "$HOME/.env-local"

exec 9>&1 1>/dev/null
git config --global --get user.name || git config --global user.name "${GIT_USER_NAME:-Mike Perry}"
git config --global --get user.email || git config --global user.email "${GIT_USER_EMAIL:-mike@bitbistro.org}"
[ -z "${GIT_SIGNINGKEY:-}" ] || git config --global --get user.signingkey || git config --global user.signingkey "$GIT_SIGNINGKEY"
git config --global --get commit.gpgsign || git config --global commit.gpgsign "true"
git config --global --get gpg.program || git config --global gpg.program "gpg"
git config --global --get init.defaultBranch || git config --global init.defaultBranch "main"
git config --global --get push.default || git config --global push.default "simple"
git config --global --get push.autoSetupRemote || git config --global push.autoSetupRemote "true"
git config --global --get pull.rebase || git config --global pull.rebase "false"
git config --global --get branch.master.merge || git config --global branch.master.merge "refs/heads/main"
git config --global --get diff.tool || git config --global diff.tool "nvimdiff"
git config --global --get core.editor || git config --global core.editor "vim"
git config --global --get core.safecrlf || git config --global core.safecrlf "true"
git config --global --get core.pager || git config --global core.pager "$(command -v less) -FRiX"
git config --global --get core.excludesFile || git config --global core.excludesFile "$HOME/.gitignore"
git config --global --get apply.whitespace || git config --global apply.whitespace "trailing-space,space-before-tab,blank-at-eol,blank-at-eof"
git config --global --get alias.pick || git config --global alias.pick "cherry-pick"
git config --global --get alias.orphans || git config --global alias.orphans "!git fetch -p; git remote prune origin; git checkout -d; git branch -vv --color=never | sed -nre \"s/^([[:space:]]+)([^[:space:]]+)[[:space:]].*\\[origin[^:]+: gone\\].*/\\2/p\" || echo none >&2"
git config --global --get alias.mod || git config --global alias.mod '!go mod'
git config --global --get alias.graph || git config --global alias.graph "log --oneline --graph"
git config --global --get alias.fpush || git config --global alias.fpush '!f() { args="$@"; args=$(echo "$args" | sed "s/\b-f\b/--force-with-lease/g"); args=$(echo "$args" | sed "s/\b--force\b/--force-with-lease/g"); args=$(echo "$args" | sed "s/-f\([a-zA-Z]\)/-\1 --force-with-lease/g"); git push $args; }; f'
git config --global --get alias.ff || git config --global alias.ff "pull --no-commit --ff-only origin"
git config --global --get alias.alias || git config --global alias.alias '!git config --global -l | '"awk -F'.' '/^alias\./&&"'!'"/^alias.alias/ {print "'"alias",$2}'"'"
exec 1>&9 9>&-
