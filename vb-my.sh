#!/bin/sh
REPO_URL="https://raw.githubusercontent.com/stroncium/arch-install/master/"
SCRIPT_CHROOT="vb-my-chroot.sh"

ntpdate time1.google.com
 
# partitions
sgdisk \
-n 1:2048:+512m -c 1:boot \
-n 2:0:+32m -c 2:gpt -t 2:ef02 \
-n 4:0:0 -c 4:root \
/dev/sda
 
# file system
mkfs.ext4 -L boot /dev/sda1 >/dev/null 2>&1
mkfs.ext4 -L root /dev/sda4 >/dev/null 2>&1

#ARCH=x86_64
ARCH=i686
ARCH_ROOT=/mnt
 
mkdir $ARCH_ROOT
mount /dev/sda4 $ARCH_ROOT
mkdir $ARCH_ROOT/boot
mount /dev/sda1 $ARCH_ROOT/boot
 
pacstrap $ARCH_ROOT base base-devel grub sudo wget postfix net-tools
 
# fstab
genfstab -p $ARCH_ROOT >> $ARCH_ROOT/etc/fstab
 
# chroot
mv $ARCH_ROOT/etc/resolv.conf{,.save}
cp /etc/resolv.conf $ARCH_ROOT/etc

mount -o bind /dev $ARCH_ROOT/dev
mount -o bind /proc $ARCH_ROOT/proc
mount -o bind /run $ARCH_ROOT/run
mount -o bind /sys $ARCH_ROOT/sys

cd $ARCH_ROOT
wget -q $REPO_URL/$SCRIPT_CHROOT -O $SCRIPT_CHROOT
chroot $ARCH_ROOT /bin/sh $SCRIPT_CHROOT
rm $SCRIPT_CHROOT 
umount $ARCH_ROOT/{boot,dev,proc,run,sys,}
shutdown -r now
