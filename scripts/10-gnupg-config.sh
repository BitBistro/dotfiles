#!/bin/bash

#if ! grep -q enable-ssh-support $HOME/.gnupg
echo enable-ssh-support > $HOME/.gnupg/gpg-agent.conf
echo pinentry-program /usr/bin/pinentry-tty >> $HOME/.gnupg/gpg-agent.conf

gpg-connect-agent <<< RELOADAGENT &>/dev/null
