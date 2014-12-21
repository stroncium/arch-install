#!/bin/sh
REPO_URL="https://raw.githubusercontent.com/stroncium/arch-install/master/"
SCRIPT_CHROOT="vb-my-chroot.sh"

function STEP(){
 echo === $@
 echo ============================================
}

STEP SETTING TIME
ntpdate time1.google.com
 
STEP PARTITIONING
sgdisk -o \
-n 1:2048:+512m -c 1:boot \
-n 2:0:+32m -c 2:gpt -t 2:ef02 \
-n 3:0:0 -c 3:root \
/dev/sda
 
STEP PERPARING FILESYSTEMS
mkfs.ext4 -L boot /dev/sda1 >/dev/null 2>&1
mkfs.ext4 -L root /dev/sda3 >/dev/null 2>&1

#ARCH=x86_64
ARCH=i686
ARCH_ROOT=/mnt

STEP MOUNTING 
mount /dev/sda3 $ARCH_ROOT
mkdir $ARCH_ROOT/boot
mount /dev/sda1 $ARCH_ROOT/boot

STEP PACSTRAP
#pacstrap $ARCH_ROOT base base-devel grub sudo wget postfix net-tools
pacstrap $ARCH_ROOT base grub wget net-tools
 
STEP MAKING FSTAB
genfstab -p $ARCH_ROOT >> $ARCH_ROOT/etc/fstab

STEP ADDITIONAL MOUNTING
mount -o bind /dev $ARCH_ROOT/dev
mount -o bind /proc $ARCH_ROOT/proc
mount -o bind /run $ARCH_ROOT/run
mount -o bind /sys $ARCH_ROOT/sys

STEP COPYING resolv.conf 
mv $ARCH_ROOT/etc/resolv.conf{,.save}
cp /etc/resolv.conf $ARCH_ROOT/etc

STEP ENTERING DIR
cd $ARCH_ROOT

STEP GETTING CHROOT SCRIPT
wget -q $REPO_URL/$SCRIPT_CHROOT -O $SCRIPT_CHROOT
bash
STEP CHROOT
chroot $ARCH_ROOT /bin/sh $SCRIPT_CHROOT

STEP REMOVING CHROOT SCRIPT
rm $SCRIPT_CHROOT 

STEP LEAVING DIR
cd /

STEP UNMOUNTING
umount $ARCH_ROOT/{boot,dev,proc,run,sys,}

STEP REBOOT
echo shutdown -r now
#shutdown -r now
