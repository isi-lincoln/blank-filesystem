# set up resolvers so we can talk to the internet
cat <<'EOF' > /etc/resolv.conf
nameserver 8.8.8.8
EOF

dnf --releasever=27 --nogpgcheck install -y sudo
yum --releasever=27 clean all
dnf --releasever=27 clean packages

# TODO: note there is no root partition in fstab
# would like to get uuid from parted and pass that in here
# as the root partition

cat <<'EOF' > /etc/fstab
proc             /proc         proc    defaults                 0    0
sys              /sys          sysfs   defaults                 0    0
EOF

useradd -s /bin/bash -m -p "e/CBifV4.zT.6" test
echo "test ALL=(ALL) ALL" >> /etc/sudoers
usermod test -a -G wheel
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# disable all the audit output
systemctl disable auditd

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

sed -ie 's/id:5:initdefault:/id:3:initdefault:/g' /etc/inittab

# leave chroot
exit
