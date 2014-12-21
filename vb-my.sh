#!/bin/sh
REPO_URL="https://raw.githubusercontent.com/stroncium/arch-install/master/"
SCRIPT_CHROOT="vb-my-chroot.sh"
#ARCH=x86_64
ARCH=i686
ARCH_ROOT=/mnt
WM_PACKAGES=ttf-dejavu lxde upower
MISC_PACKAGES=alsa-utils
VB_PACKAGES=virtualbox-guest-utils virtualbox-guest-modules

function STEP(){
 echo === $@
}

#STEP SETTING TIME
#ntpdate time1.google.com
 
STEP PARTITIONING
sgdisk -o \
-n 1:2048:+512m -c 1:boot \
-n 2:0:+32m -c 2:gpt -t 2:ef02 \
-n 3:0:0 -c 3:root \
/dev/sda
 
STEP FORMATTING
mkfs.ext4 -L boot /dev/sda1
mkfs.ext4 -L root /dev/sda3

STEP MOUNTING 
mount /dev/sda3 $ARCH_ROOT
mkdir $ARCH_ROOT/boot
mount /dev/sda1 $ARCH_ROOT/boot

STEP PACSTRAP
#pacstrap $ARCH_ROOT base base-devel grub sudo wget postfix net-tools
pacstrap $ARCH_ROOT base grub wget net-tools zsh sudo $VB_PACKAGES $WM_PACKAGES $MISC_PACKAGES
 
STEP MAKING FSTAB
genfstab -p $ARCH_ROOT >> $ARCH_ROOT/etc/fstab

STEP ADDITIONAL MOUNTING
mount -o bind /dev $ARCH_ROOT/dev
mount -o bind /proc $ARCH_ROOT/proc
mount -o bind /run $ARCH_ROOT/run
mount -o bind /sys $ARCH_ROOT/sys

#STEP COPYING resolv.conf 
#mv $ARCH_ROOT/etc/resolv.conf{,.save}
#cp /etc/resolv.conf $ARCH_ROOT/etc

STEP GETTING CHROOT SCRIPT
wget -q $REPO_URL/$SCRIPT_CHROOT -O $ARCH_ROOT/$SCRIPT_CHROOT

STEP CHROOT
chroot $ARCH_ROOT /bin/sh $SCRIPT_CHROOT

STEP REMOVING CHROOT SCRIPT
rm $ARCH_ROOT/$SCRIPT_CHROOT

STEP ADDITIONAL UMOUNTING
umount $ARCH_ROOT/{dev,proc,run,sys}

STEP UMOUNTING
umount $ARCH_ROOT/boot $ARCH_ROOT


STEP REBOOT
echo shutdown -r now
#shutdown -r now
