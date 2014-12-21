#!/bin/sh

ARCH_TZ="Europe/Moscow"
ARCH_HN="stronzi-razer-vb"
ARCH_LOCALE="en_US.UTF-8"

echo $ARCH_TZ > /etc/timezone
ln -sf /usr/share/zoneinfo/$ARCH_TZ /etc/localtime
hwclock --systohc --localtime
 
echo $ARCH_HN > /etc/hostname
#sed -i '6,7s/$/\tarch/' /etc/hosts
 
cat > /etc/netctl/eth0 <<DELIM
Description='A basic static ethernet connection'
Interface=eth0
Connection=ethernet
IP=static
Address=('10.0.2.15/24')
Gateway='10.0.2.2'
DNS=('114.114.114.114')
DELIM
# workaround for eth0 renaming
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
 
# locale
echo LANG=$ARCH_LOCALE > /etc/locale.conf
sed -i -e /^#$ARCH_LOCALE/s/#// /etc/locale.gen
locale-gen

source /etc/profile
 
# modprobe
cat > /etc/modprobe.d/virtualbox.conf <<DELIM
blacklist i2c_piix4
blacklist lpc_ich
DELIM
 
# mkinitcpio
sed -i '/#COMPRESSION="xz"/s/^#//' /etc/mkinitcpio.conf
mkinitcpio -p linux
 
useradd -m -G users,wheel -s /bin/bash stronzi

# grub
sed -i \
-e '/^#GRUB_DISABLE_LINUX_UUID/s/#//' \
-e '/^#GRUB_COLOR/s/#//' \
-e '/GRUB_CMDLINE_LINUX/s/""/"ipv6.disable=1"/' \
/etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sda
 
/bin/bash
exit
