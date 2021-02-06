#!/bin/bash
command find -P ~/.ssh ~/.gnupg -type d -exec /bin/chmod -v 700 {} \;
command find -P ~/.ssh ~/.gnupg -type f -exec /bin/chmod -v 600 {} \;
