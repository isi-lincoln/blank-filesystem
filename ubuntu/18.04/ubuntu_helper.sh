#!/bin/bash

UUID=""
if [ $# -eq 1 ]; then
	UUID="$1"
	echo "Set UUID: " $UUID
fi

# add security and source to deb list
cat <<'EOF' > /etc/apt/sources.list
deb http://in.archive.ubuntu.com/ubuntu/ bionic main universe
deb-src http://in.archive.ubuntu.com/ubuntu/ bionic main universe

deb http://security.ubuntu.com/ubuntu bionic-security main universe
deb-src http://security.ubuntu.com/ubuntu bionic-security main universe
EOF

# set up the device files
cat <<EOF > /etc/fstab 
/dev/sda1	/	ext4	defaults	0	1
proc		/proc	proc	defaults	0	0
sys		/sys	sysfs	defaults	0	0
EOF

# verify we have a good fstab
cat /etc/fstab
mkdir -p /dev
# mount proc and sys
mount -t proc proc /proc
mount -t sysfs sysfs /sys

# in chroot environment - prepare the filesystem for use
apt-get update
apt-get install -y makedev

# make the devices /dev
cd /dev
MAKEDEV generic
# go back to root
cd /

# set up resolvers so we can talk to the internet
cat <<'EOF' > /etc/resolv.conf
nameserver 8.8.8.8
EOF


# set up time/locale
cat <<'EOF' > /tzdata.conf
tzdata tzdata/Areas select US
tzdata tzdata/Zones/US select Pacific
EOF
debconf-set-selections /tzdata.conf
rm /etc/timezone
rm /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# refresh the deb lists
apt-get update

# install sudo before we mess with sudoers
apt-get install -qy sudo

# set up using openssl passwd -crypt
# username: test, password: test
useradd -s /bin/bash -m -p "e/CBifV4.zT.6" test
addgroup --system admin
adduser test admin
echo "admin ALL=(ALL) ALL" >> /etc/sudoers

# this is a subset of tasksel standard
# if you dont mind the extra space:
# apt-get install tasksel
# tasksel install standard
DEBIAN_FRONTEND=noninteractive apt-get install -qy \
manpages \
parted \
time \
file \
vim-tiny \
iputils-ping \
iproute2 \
net-tools \
bash-completion \
wget \
iptables \
isc-dhcp-client \
lsb-release \
man-db \
systemd \
openssh-server \
keyboard-configuration \
linux-image-generic \
ca-certificates \
less

# we need this to configure 1) keyboard 2) grub
# TODO: non-interactive would be kev
dpkg --configure -a

# dont let the sucker try and boot into graphical
systemctl enable multi-user.target
systemctl set-default multi-user.target

# put in a rule for having the networks dhcp on boot
cat <<'EOF' > /etc/systemd/network/20-wired.network
[Match]
Name=ens*

[Network]
DHCP=yes
EOF
systemctl enable systemd-networkd.service

# set hostname
echo ubuntu1804 > /etc/hostname

# clean up some of the packaging
apt clean
apt-get autoclean

# create a usuable initramfs
update-initramfs -u -k all

# leave chroot
exit
