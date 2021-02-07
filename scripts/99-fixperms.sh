#!/bin/bash
command find -P ~/.ssh ~/.gnupg -type d -exec /bin/chmod 700 {} \;
command find -P ~/.ssh ~/.gnupg -type f -exec /bin/chmod 600 {} \;
