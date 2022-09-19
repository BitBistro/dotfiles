#!/bin/bash

if [ -n "$1" ]; then
    STAGE="$1"
fi

if [ -z "$STAGE" ]; then
    STAGE="help"
fi

if [ `id -u` -ne '0' ]; then
    if [ -z $NO_RECURSE ]; then
        exec sudo NO_RECURSE=1 /bin/bash -e "$0" "$STAGE"
    else
        echo "This must be run as root" >&2 && false
    fi
fi

NVME=/dev/disk/by-id/nvme-WDS500G3X0C-00SJG0_21100C801241
ATA=/dev/disk/by-id/ata-WDC_WD10SPSX-22A6WT0_WD-WX91AB9273U8-part5
TEMPFILE="$(mktemp)"
trap '/bin/rm -f -- "$TEMPFILE"' EXIT
TARGET="/mnt/target"
SOURCE="/mnt/source"
mkdir -p $TARGET $SOURCE

case $STAGE in
    "help")
        echo "$0 ( prep | create | chroot )" >&2
    ;;
    "prep")
        apt install --yes openssh-server
        systemctl restart ssh

        apt install --yes debootstrap gdisk dkms dpkg-dev \
            linux-headers-$(uname -r)
        apt install --yes --no-install-recommends zfs-dkms

        modprobe zfs
        apt install --yes zfsutils-linux
    ;;
    "create")

        zpool create \
            -o ashift=12 -O overlay=on \
            -O acltype=posixacl -O canmount=off -O compression=lz4 \
            -O dnodesize=auto -O relatime=on  -O aclmode=passthrough \
            -O aclinherit=passthrough -O xattr=sa -O mountpoint=/ -R ${TARGET} \
            zroot ${NVME}

        zpool create \
            -o ashift=12 -O overlay=on \
            -O acltype=posixacl -O canmount=off -O compression=lz4 \
            -O dnodesize=auto -O relatime=on  -O aclmode=passthrough \
            -O aclinherit=passthrough -O xattr=sa -O mountpoint=/ -R ${TARGET} \
            tank ${ATA}

        zfs create -o canmount=off -o mountpoint=none zroot/ROOT
        zfs create -o canmount=noauto -o mountpoint=/ zroot/ROOT/default
        zfs mount zroot/ROOT/default; mkdir ${TARGET}/etc/zfs
        zfs create tank/home
        zfs create -o mountpoint=/root tank/home/root
        zfs create zroot/srv
        zfs create -o com.sun:auto-snapshot=false tank/tmp
        zfs create -o canmount=off zroot/usr; mkdir ${TARGET}/usr
        zfs create zroot/usr/local
        zfs create zroot/usr/src
        zfs create tank/var
        zfs create -o canmount=off zroot/var
        zfs create -o com.sun:auto-snapshot=false zroot/var/cache
        zfs create -o canmount=off zroot/var/lib; mkdir ${TARGET}/var/lib
        zfs create -o com.sun:auto-snapshot=false zroot/var/lib/docker
        zfs create -o com.sun:auto-snapshot=false tank/var/tmp

        #cp /etc/zfs/zpool.cache ${TARGET}/etc/zfs/
    ;;
    "copy_setup")
        lvcreate --size 1G --snapshot --name snap_root /dev/mapper/cg4-root
        lvcreate --size 1G --snapshot --name snap_var /dev/mapper/cg4-var
        lvcreate --size 1G --snapshot --name snap_home /dev/mapper/cg4-home
        mount -o ro /dev/mapper/cg4-snap_root ${SOURCE}
        mount -o ro /dev/mapper/cg4-snap_var ${SOURCE}/var
        mount -o ro /dev/mapper/cg4-snap_home ${SOURCE}/home
        mkdir -p ${TARGET}/{dev,proc,sys,run,var,home,tmp,boot,run/lock,var/tmp}
        mount --rbind /dev  ${TARGET}/dev
        mount --rbind /proc ${TARGET}/proc
        mount --rbind /sys  ${TARGET}/sys
        mount --bind /boot  ${TARGET}/boot
        mount --bind /boot  ${TARGET}/boot/efi
        mount -t tmpfs tmpfs ${TARGET}/run
        mount -t tmpfs tmpfs ${TARGET}/tmp
        mount -t tmpfs tmpfs ${TARGET}/var/tmp
        chmod 1777 ${TARGET}/var/tmp ${TARGET}/tmp
    ;;
    "copy_data")
        rsync -aHAX ${SOURCE}/ ${TARGET}/
        chmod 1777 ${TARGET}/var/tmp ${TARGET}/tmp
        chmod 700 ${TARGET}/root
    ;;
    "copy_teardown")
        for MNT in `awk '$2~/\/mnt\/(source|target)/ {print $2}' /proc/mounts`; do
            echo umount -l ${MNT}
        done
        exit
        sudo lvremove --yes /dev/mapper/cg4-snap_root
        sudo lvremove --yes /dev/mapper/cg4-snap_var
        sudo lvremove --yes /dev/mapper/cg4-snap_home
    ;;
    "chroot")
        mkdir /etc/zfs/zfs-list.cache
        touch /etc/zfs/zfs-list.cache/zroot
        touch /etc/zfs/zfs-list.cache/tank
        zpool set cachefile=/etc/zfs/zpool.cache zroot
        zpool set cachefile=/etc/zfs/zpool.cache tank
    ;;
    "wrapup")
    ;;
    *)
        echo "Not implemented" >&2
        exit 1
    ;;
esac

exit 0
