BASEDIR="$1"
OSENV="$2"

if [ "$OSENV" = "linux" ]; then
    exit 0

    if [ ! -f "/usr/share/keyrings/xpra-2022.gpg" ]; then
        sudo wget -O "/usr/share/keyrings/xpra-2022.gpg" https://xpra.org/xpra-2022.gpg
    fi
    if [ ! -f "/usr/share/keyrings/xpra-2018.gpg" ]; then
        sudo wget -O "/usr/share/keyrings/xpra-2018.gpg" https://xpra.org/xpra-2018.gpg
    fi

    if [ ! -f "/etc/apt/sources.list.d/xpra.list" ]; then
        sudo wget -O "/etc/apt/sources.list.d/xpra.list" https://xpra.org/repos/bullseye/xpra.list
    fi

    sudo apt update
    sudo apt install xpra

fi
