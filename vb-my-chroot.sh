#!/bin/sh
ARCH_TZ="Europe/Moscow"
ARCH_HN="stronzi-razer-vb"
ARCH_LOCALE="en_US.UTF-8"
ARCH_USER="stronzi"

function STEP(){
 echo === === $@
}

STEP TIMEZONE $ARCH_TZ
echo $ARCH_TZ > /etc/timezone
ln -sf /usr/share/zoneinfo/$ARCH_TZ /etc/localtime

STEP CLOCK SYNC
hwclock --systohc --localtime

STEP HOSTNAME $ARCH_HN
echo $ARCH_HN > /etc/hostname

#cat > /etc/netctl/eth0 <<EOF
#Description='static ethernet'
#Interface=eth0
#Connection=ethernet
#IP=static
#Address=('10.0.2.15/24')
#Gateway='10.0.2.2'
#DNS=('8.8.8.8')
#EOF

STEP WORKAROUND FOR eth0 RENAMING
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
 
STEP LOCALE $ARCH_LOCALE
echo LANG=$ARCH_LOCALE > /etc/locale.conf
sed -i -e /^#$ARCH_LOCALE/s/#// /etc/locale.gen
locale-gen

source /etc/profile
 
STEP MODPROBE for VirtualBox
cat > /etc/modprobe.d/virtualbox.conf <<EOF
blacklist i2c_piix4
blacklist lpc_ich
EOF

STEP modules for VirtualBox
cat > /etc/modules-load.d/virtualbox.conf <<EOF
vboxguest
vboxsf
vboxvideo
EOF

STEP mkinitcpio
#sed -i '/#COMPRESSION="xz"/s/^#//' /etc/mkinitcpio.conf
mkinitcpio -p linux

STEP USER $ARCH_USER
useradd -m -G users,wheel -s /bin/bash $ARCH_USER

#STEP root password set to root
#echo -e "root\nroot" | passwd root

STEP $ARCH_USER password set to $ARCH_USER
echo -e "$ARCH_USER\n$ARCH_USER" | passwd $ARCH_USER

STEP ADDING $ARCH_USER TO sudoers.d
echo "$ARCH_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$ARCH_USER

STEP GRUB
sed -i \
  -e '/^#GRUB_DISABLE_LINUX_UUID/s/#//' \
  -e '/^#GRUB_COLOR/s/#//' \
  -e '/^GRUB_CMDLINE_LINUX/s/""/"ipv6.disable=1"/' \
  -e '/^GRUB_TIMEOUT/s/=.*$/=1/'
  /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install /dev/sda

STEP ENABLING vboxservice
systemctl enable vboxservice

STEP ENABLING dhcpcd
systemctl enable dhcpcd

STEP RUNNING BASH, exit to continue
/bin/bash 
exit
