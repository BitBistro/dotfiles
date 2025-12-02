if [ ! /usr/bin/git ]; then
    echo "Git not installed... bailing"
    exit 255;
fi
exec 9>&1 1>/dev/null
git config --global --get user.name || git config --global user.name "Mike Perry"
git config --global --get user.email || git config --global user.email "mike@bitbistro.org"
git config --global --get pull.rebase || git config --global pull.rebase "false"
git config --global --get gpg.program || git config --global gpg.program "gpg"
git config --global --get diff.tool || git config --global diff.tool "vimdiff"
git config --global --get core.safecrlf || git config --global core.safecrlf "true"
git config --global --get core.pager || git config --global core.pager "$(command -v less) -FRiX"
git config --global --get core.excludesFiles || git config --global core.excludesFiles "$HOME/.gitignore"
git config --global --get apply.whitespace || git config --global apply.whitespace "trailing-space,space-before-tab,blank-at-eol,blank-at-eof"
git config --global --get alias.push || git config --global alias.push '!f() { args="$@"; args=$(echo "$args" | sed "s/\b-f\b/--force-with-lease/g"); args=$(echo "$args" | sed "s/\b--force\b/--force-with-lease/g"); args=$(echo "$args" | sed "s/-f\([a-zA-Z]\)/-\1 --force-with-lease/g"); git-push $args; }; f'
git config --global --get alias.pick || git config --global alias.pick "cherry-pick"
git config --global --get alias.orphans || git config --global alias.orphans "!git fetch -p; git remote prune origin; git checkout -d; git branch -vv --color=never | sed -nre \"s/^([[:space:]]+)([^[:space:]]+)[[:space:]].*\\[origin[^:]+: gone\\].*/\\2/p\" || echo none >&2"
git config --global --get alias.mod || git config --global alias.mod '!go mod'
git config --global --get alias.graph || git config --global alias.graph "log --oneline --graph"
git config --global --get alias.ff || git config --global alias.ff "pull --no-commit --ff-only origin"
git config --global --get alias.alias || git config --global alias.alias '!git config --global -l | '"awk -F'.' '/^alias\./&&"'!'"/^alias.alias/ {print "'"alias",$2}'"'"
exec 1>&9 9>&-
