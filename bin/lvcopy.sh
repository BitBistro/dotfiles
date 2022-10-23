#!/bin/bash
set -e

if [ -z "$2" ]; then
	THIS="$(df -hP / | awk '!/Filesystem/ {print $1; exit}')"
	THAT="$1"
else
	THIS="$1"
	THAT="$2"
fi

if [ -z "$THIS" ]; then
	echo "Must set \$THIS to this root"
	exit 1
fi

if [ -z "$THAT" ]; then
	echo "Must set \$THAT to next root"
	exit 2
fi

echo "THIS: $THIS, THAT: $THAT"
echo "Continue?"
read -n1 yn; echo
if [ "$yn" != "y" ]; then
	echo "Aborting..."
fi

set -vex
journalctl --flush
journalctl --relinquish-var
lvconvert --type mirror --alloc anywhere -m1 "$THIS"
lvconvert --splitmirrors 1 --name "$THAT" "$THIS"
mkdir -p /mnt/next
mount "$THAT" /mnt/next
sed -i~ -re 's#'"$THIS"'#'"$THAT"'#' /mnt/next/etc/fstab
rm /mnt/next/etc/fstab~
umount /mnt/next
update-grub
rm -v /boot/grub/grub.cfg.old || true
sed -i.old -re 's#'"$THIS"'#'"$THAT"'#g' /boot/grub/grub.cfg
set +vex
echo done
