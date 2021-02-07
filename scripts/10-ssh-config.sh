#!/bin/bash

# https://bugzilla.mindrot.org/show_bug.cgi?id=2824#c9
if ! grep -q UPDATESTARTUPTTY $HOME/.ssh/config 2>/dev/null ; then
    echo 'Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"' >> "$HOME/.ssh/config"
fi
