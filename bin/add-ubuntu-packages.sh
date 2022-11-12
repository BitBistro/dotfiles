#!/bin/bash
set -e
BASEDIR="$(readlink -f `dirname  $0`/..)";
#. $BASEDIR/overlay/.env

if [ -n "$1" ]; then
    LEVEL="$1"
fi

if [ -z "$LEVEL" ]; then
    LEVEL="base"
fi

if [ `id -u` -ne '0' ]; then
    if [ -z $NO_RECURSE ]; then
        exec sudo NO_RECURSE=1 /bin/bash -e "$0" "$LEVEL"
    else
        echo "This must be run as root" >&2 && false
    fi
fi

TEMPFILE="$(mktemp)"
trap '/bin/rm -f -- "$TEMPFILE"' EXIT
apt-config dump | egrep 'APT::Install' | sed -re 's/1/0/g' > $TEMPFILE
export APT_CONFIG="$TEMPFILE"

apt update
apt autoremove

case $LEVEL in
    "base")
        apt upgrade
        apt install aptitude aptitude-doc-en
        aptitude install "?and(?architecture(native),?or(~prequired))" bash-completion vim-nox git rsync pinentry-tty\
                pinentry-curses_ gpg-agent
    ;;
    "standard")
        aptitude -r install '?and(?architecture(native),?or(~prequired,~pimportant,~pstandard),?not(~v),?not(~slibs))' \
		ubuntu-server bash-completion vim-nox git rsync pinentry-tty pinentry-curses_ gpg-agent rsync patch \
		zip unzip jq plocate neovim restic curl openssl bsdutils ncal rfkill wpasupplicant w3m parted bc dc \
		kmod btrfs-progs tcpdump wget wodim busybox-static zfs-dkms zfs-initramfs ssh
        aptitude unmarkauto '?and(?architecture(native),?or(~prequired,~pimportant,~pstandard),?not(~v),?not(~slibs),~i)' \
		ubuntu-server bash-completion vim-nox git rsync pinentry-tty pinentry-curses_ gpg-agent rsync patch \
		zip unzip jq plocate neovim restic curl openssl bsdutils ncal rfkill wpasupplicant w3m parted bc dc \
		kmod btrfs-progs tcpdump wget wodim busybox-static zfs-dkms zfs-initramfs ssh
    ;;
    "extra")
        aptitude install \
            apt-file arch-test autoconf automake autotools-dev build-essential debhelper debian-keyring debootstrap \
            devscripts dh-make dkms dosfstools dpkg-dev dput dupload e2fsprogs-l10n eatmydata equivs fakeroot fancontrol \
            gdisk gnupg hdparm htop i2c-tools irqbalance jq lintian shared-mime-info xauth linux-headers-generic fbset \
            lm-sensors localepurge manpages-dev mlocate mutt net-tools nocache nvme-cli parted patch patchutils pbuilder pigz \
            powermgmt-base read-edid screen smartmontools strace thin-provisioning-tools xutils-dev xdg-user-dirs neovim gdb \
	    linux-doc info iw bison flex gnupg libncurses-dev libelf-dev libssl-dev zstd cpio dwarves xsel upower alsa-utils \
            debconf-utils eject ethtool packagekit cifs-utils ntfs-3g vdpau-driver-all va-driver-all exfatprogs exfat-fuse \
    ;;
    "thisbe")
    	aptitude install \
	    '?and(~n^firmware,!~nnvidia,!microbit)' intel-gpu-tools 
    ;;
    "desktop")
        aptitude -t bullseye-backports -o APT::Install-Recommends=true -o APT::Get::AutomaticRemove=true -o Acquire::Retries=3 \
            install task-desktop task-xfce-desktop task-ssh-server xdg-desktop-portal-gtk_ xdg-desktop-portal_ plymouth-label_ \
            libegl1-mesa
    ;;
    "cleanup")
        dpkg -l | awk 'c&&!/ii/{print $2}/^\+/{c=1}' | xargs aptitude purge -t bullseye-backports -y
    ;;
    "zfs")
    	aptitude install \
	    linux-headers-$(uname -r) zfs-dkms zfs-initramfs
    ;;
    "kvm") 
        aptitude install qemu-kvm
    ;;
    *)
        echo "Not implemented" >&2
    exit 1
esac

exit 0
