#!/bin/bash
command find -P ~/.ssh ~/.gnupg ~/.password-store -type d ! -perm 700 -exec chmod -v 700 {} \;
command find -P ~/.config ~/.cache -type d ! -perm 700 -exec chmod 700 {} \;
command find -P ~/.ssh ~/.gnupg ~/.password-store -type f ! -perm 600 -exec chmod -v 600 {} \;
command find -P ~/.local -maxdepth 2 -type d ! -perm 711 -exec chmod 711 {} \;
command find ~/C ~/C/dev ~/C/go -maxdepth 0 -type d ! -perm 711 -exec chmod -v 711 {} \;
