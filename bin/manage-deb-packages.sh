#!/bin/bash
set -e
LEVEL="${1:-base}"

if [ "$LEVEL" != "audit" ] && [ "$(id -u)" -ne '0' ]; then
    if [ -z "$NO_RECURSE" ]; then
        exec sudo NO_RECURSE=1 /bin/bash -e "$0" "$LEVEL"
    else
        echo "This must be run as root" >&2 && false
    fi
fi

TEMPFILE="$(mktemp)"
trap 'rm -f -- "$TEMPFILE"' EXIT
apt-config dump | grep -E 'APT::Install' | sed -re 's/1/0/g' > "$TEMPFILE"
export APT_CONFIG="$TEMPFILE"
export DEBIAN_FRONTEND=noninteractive

if [ "$LEVEL" != "audit" ]; then
    apt update
fi

case "$LEVEL" in
    "base")
        apt -y upgrade
        apt -y install aptitude aptitude-doc-en
        aptitude -y install "?and(?architecture(native),?or(~prequired))" bash-completion vim-nox git rsync pinentry-tty \
                pinentry-curses_ gpg-agent sudo tasksel
    ;;
    "standard")
        aptitude -r install '?and(?architecture(native),?or(~prequired,~pimportant,~pstandard),?not(~v),?not(~slibs))' \
                bsd-mailx exim4-daemon-light patch zip unzip jq \
                plocate '?and(~n^plymouth_,?not(~v))' neovim restic curl openssl bsdutils ncal rfkill \
                wpasupplicant w3m parted bc dc kmod btrfs-progs tcpdump wget wodim busybox-static pinentry-fltk pass \
                dbus dbus-user-session ripgrep tree yq gpg dos2unix whois
        aptitude unmarkauto '?and(?architecture(native),?or(~prequired,~pimportant,~pstandard),?not(~v),?not(~slibs),~i)' \
                bsd-mailx exim4-daemon-light patch zip unzip jq \
                plocate neovim restic curl openssl bsdutils ncal rfkill wpasupplicant w3m parted bc dc kmod btrfs-progs \
                tcpdump wget wodim busybox-static pinentry-fltk pass dbus dbus-user-session ripgrep tree yq gpg dos2unix whois
    ;;
    "extra")
        aptitude install \
            apt-file arch-test autoconf automake autotools-dev build-essential debhelper debian-keyring debootstrap \
            devscripts dh-make dkms dosfstools dpkg-dev dput dupload e2fsprogs-l10n eatmydata equivs fakeroot fancontrol \
            gdisk gnupg hdparm htop i2c-tools irqbalance imagemagick lintian shared-mime-info xauth linux-headers-amd64 \
            lm-sensors localepurge manpages-dev mutt net-tools nocache nvme-cli patchutils pbuilder pigz \
            powermgmt-base read-edid screen smartmontools strace thin-provisioning-tools xutils-dev xdg-user-dirs gdb \
            linux-doc info iw bison flex libncurses-dev libelf-dev libssl-dev zstd cpio dwarves xsel upower alsa-utils \
            debconf-utils eject ethtool packagekit cifs-utils vdpau-driver-all va-driver-all exfatprogs exfat-fuse \
            fbset '?and(~n^mesa,?not(~v))' xdg-utils x11-utils x11-xserver-utils git-filter-repo libsecret-tools \
            shellcheck task-ssh-server gh pkgconf fd-find sqlite3 x11-apps xterm bubblewrap ripgrep-all ffmpeg poppler-utils
    ;;
    "audit")
        EXPLICIT_LIST=(
            aptitude aptitude-doc-en bash-completion vim-nox git rsync pinentry-tty gpg-agent sudo tasksel
            bsd-mailx exim4-daemon-light patch zip unzip jq plocate neovim restic curl openssl
            bsdutils ncal rfkill wpasupplicant w3m parted bc dc kmod btrfs-progs tcpdump wget
            wodim busybox-static pinentry-fltk pass dbus dbus-user-session ripgrep tree yq gpg dos2unix whois
            apt-file arch-test autoconf automake autotools-dev build-essential debhelper
            debian-keyring debootstrap devscripts dh-make dkms dosfstools dpkg-dev dput
            dupload e2fsprogs-l10n eatmydata equivs fakeroot fancontrol gdisk gnupg hdparm
            htop i2c-tools irqbalance imagemagick lintian shared-mime-info xauth linux-headers-amd64
            lm-sensors localepurge manpages-dev mutt net-tools nocache nvme-cli patchutils
            pbuilder pigz powermgmt-base read-edid screen smartmontools strace
            thin-provisioning-tools xutils-dev xdg-user-dirs gdb linux-doc info iw bison
            flex libncurses-dev libelf-dev libssl-dev zstd cpio dwarves xsel upower alsa-utils
            debconf-utils eject ethtool packagekit cifs-utils vdpau-driver-all va-driver-all
            exfatprogs exfat-fuse fbset '?and(~n^mesa,?not(~v))' xdg-utils x11-utils x11-xserver-utils git-filter-repo
            libsecret-tools shellcheck task-ssh-server terraform helm gh pkgconf fd-find sqlite3 x11-apps xterm bubblewrap ripgrep-all ffmpeg poppler-utils
        )
        manual_pkgs="$(aptitude search -F '%p' '?and(?installed, ?not(?automatic), ?not(~slibs), ?not(~v))' | sort -u)"
        priority_pkgs="$(aptitude search -F '%p' '?and(?installed, ?or(~prequired,~pimportant,~pstandard))' | sort -u)"
        pattern_pkgs="$(aptitude search -F '%p' '?and(?installed, ?or(~n^plymouth_, ~n^mesa, ~n^dbus))' | sort -u)"
        explicit_pkgs="$(printf '%s\n' "${EXPLICIT_LIST[@]}" | sort -u)"

        allowed_pkgs="$(printf '%s\n' "$priority_pkgs" "$pattern_pkgs" "$explicit_pkgs" | sort -u)"

        comm -23 <(echo "$manual_pkgs") <(echo "$allowed_pkgs")
    ;;
    "cleanup")
        dpkg -l | awk 'c&&!/ii/{print $2}/^\+/{c=1}' | xargs aptitude purge -y
    ;;
    "zfs")
        aptitude install \
            "linux-headers-$(uname -r)" zfs-dkms zfs-initramfs
    ;;
    "kvm") 
        aptitude install qemu-kvm
    ;;
    *)
        echo "Not implemented" >&2
    exit 1
esac

if [ "$LEVEL" != "audit" ]; then
    apt autoremove
fi

exit 0
