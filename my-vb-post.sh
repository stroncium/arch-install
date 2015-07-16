#!/bin/sh
WM_PACKAGES=ttf-dejavu lxde upower
MISC_PACKAGES=alsa-utils yajl
VB_PACKAGES=virtualbox-guest-utils virtualbox-guest-modules
sudo pacman -S  $VB_PACKAGES $WM_PACKAGES $MISC_PACKAGES

amixer -s<<EOF
  sset Master unmute
  sset Master 100%
  sset PCM unmute
  sset PCM 100%
EOF
alsactl store
#speaker-test -c2

cp /usr/lib/systemd/system/getty@.service /etc/systemd/system/autologin@.service
sed -i -e "/ExecStart/s/%I/-a $ARCH_USER %I/" /etc/systemd/system/autologin@.service
systemctl daemon-reload
systemctl disable getty@tty1
systemctl enable autologin@tty1

cp /etc/skel/.bash_profile /home/$ARCH_USER/.bash_profile
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx' >> /home/$ARCH_USER/.bash_profile

cat > /home/$ARCH_USER/.xinitrc <<EOF
/usr/bin/VBoxClient-all
exec startlxde
EOF
mkdir builds
cd builds

wget https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
tar -xf package-query.tar.gz
cd package-query
makepkg
yes | sudo pacman -U package-query-*.pkg.tar.*
cd ..

wget https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
tar -xf yaourt.tar.gz
cd yaourt
makepkg
yes | sudo pacman -U yaourt-*.pkg.tar.*
cd ..

cd ..
rm -rf builds
