#!/bin/bash

UUID=""
if [ $# -eq 1 ]; then
	UUID="$1"
	echo "Set UUID: ", $UUID
fi

apt-get update

# add security and source to deb list
cat <<'EOF' > /etc/apt/sources.list
deb http://in.archive.ubuntu.com/ubuntu/ bionic main
deb-src http://in.archive.ubuntu.com/ubuntu/ bionic main

deb http://security.ubuntu.com/ubuntu bionic-security main
deb-src http://security.ubuntu.com/ubuntu bionic-security main
EOF

# in chroot environment - prepare the filesystem for use
apt-get update
apt-get install -y makedev linux-image-generic

# set up the device files
mount none /proc -t proc
cd /dev
MAKEDEV generic
umount /proc

# TODO: note there is no root partition in fstab
tee /etc/fstab <<'EOF'
${UUID}	/	ext4	defaults	0	1
proc		/proc	proc	defaults	0	0
sys		/sys	sysfs	defaults	0	0
EOF

# try mounting everything
mount -a

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
lsof \
iputils-ping \
iproute2 \
busybox-static \
strace \
net-tools \
telnet \
lshw \
bash-completion \
wget \
ed \
iptables \
isc-dhcp-client \
tcpdump \
lsb-release \
man-db \
systemd \
openssh-server \
keyboard-configuration \
kexec-tools \
network-manager \
less

# dont let the sucker try and boot into graphical
systemctl enable multi-user.target
systemctl set-default multi-user.target

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

# leave chroot
exit
