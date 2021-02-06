#!/bin/bash
if [ ! /usr/bin/git ]; then
    echo "Git not installed... bailing"
    exit 255;
fi
echo "Setting up git as needed"
exec 9>&1 1>/dev/null
git config --global --get user.email || git config --global user.email "78653813+mikewwwperry@users.noreply.github.com"
git config --global --get user.name || git config --global user.name "Mike Perry"
git config --global --get core.pager || git config --global core.pager "$(command -v less) -FRix"
exec 1>&9 9>&-
