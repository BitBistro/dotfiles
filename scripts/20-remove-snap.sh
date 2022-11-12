BASEDIR="$1"
OSENV="$2"
FLAVOR="$3"

if [ "$FLAVOR" = "ubuntu" ]; then
    command -v snap &> /dev/null || exit 0
    snap list | egrep -v '(Notes|base|snapd)$' | awk '{print $1}' | xargs -n1 sudo snap remove --purge 
    sudo snap remove --purge bare
    sudo snap remove --purge core20
    sudo snap remove --purge snapd
    sudo aptitude purge snapd -y
    echo -e 'Package: snapd\nPin: release a=*\nPin-Priority: -10' | sudo tee /etc/apt/preferences.d/nosnap.pref
fi
