if [ ! /usr/bin/git ]; then
    echo "Git not installed... bailing"
    exit 255;
fi
exec 9>&1 1>/dev/null
git config --global --get user.email || git config --global user.email "mike@bitbistro.org"
git config --global --get user.name || git config --global user.name "Mike Perry"
git config --global --get core.pager || git config --global core.pager "$(command -v less) -FRiX"
git config --global --get pull.rebase || git config --global pull.rebase "false"
exec 1>&9 9>&-
