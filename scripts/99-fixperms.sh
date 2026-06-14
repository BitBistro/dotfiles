#!/bin/bash
command find -P ~/.ssh ~/.gnupg ~/.password-store -type d -exec /bin/chmod -v 700 {} \;
command find -P ~/.config ~/.cache -type d -exec /bin/chmod 700 {} \; 
command find -P ~/.ssh ~/.gnupg ~/.password-store -type f -exec /bin/chmod -v 600 {} \; -print
command find -P ~/.local -maxdepth 2 -type d -exec /bin/chmod 711 {} \;
chmod 711 ~/C
chmod 711 ~/C/dev
chmod 711 ~/C/go
