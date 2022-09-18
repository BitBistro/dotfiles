command find -P ~/.ssh ~/.gnupg ~/.cache ~/.config -type d -exec /bin/chmod 700 {} \;
command find -P ~/.ssh ~/.gnupg -type f -exec /bin/chmod 600 {} \;
command find -P ~/.local -type d -exec /bin/chmod 711 {} \;
