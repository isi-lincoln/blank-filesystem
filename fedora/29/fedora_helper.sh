#!/bin/bash
# in chroot environment - prepare the filesystem for use

# exit on error
set -e

# set up resolvers so we can talk to the internet
cat <<'EOF' > /etc/resolv.conf
nameserver 8.8.8.8
EOF

dnf --releasever=29 --nogpgcheck install -y sudo
dnf --releasever=29 clean packages

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

# dont let the sucker try and boot into graphical
systemctl set-default multi-user.target
rm /etc/systemd/system/default.target
ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target

# have serial console come up on systemd - again NOTE hard coded ttyS0
cat <<'EOF' > /etc/systemd/system/getty.target.wants/getty\@ttyS1.service
# http://man7.org/linux/man-pages/man8/agetty.8.html
# https://www.freedesktop.org/software/systemd/man/systemd.unit.html
# https://ubuntuforums.org/showthread.php?t=2343595
[Unit]
Description=Serial Console

# After= ensures that the configured unit is started after the listed unit finished
# starting up, Before= ensures the opposite, that the configured unit is fully started
# up before the listed unit is started.
After=systemd-user-sessions.service plymouth-quit-wait.service
After=rc-local.service
Before=getty.target

# Takes a boolean argument. If true, this unit will not be stopped when isolating
# another unit. Defaults to false for service, target, socket, busname, timer, and
# path units, and true for slice, scope, device, swap, mount, and automount units.
IgnoreOnIsolate=yes

# ConditionPathExists=/dev/tty0

[Service]
# the VT is cleared by TTYVTDisallocate
ExecStart=-/sbin/agetty %I $TERM
Type=idle
Restart=always
UtmpIdentifier=%I
TTYPath=/dev/%I
TTYReset=yes

[Install]
WantedBy=multi-user.target
DefaultInstance=tty1
EOF

sed -ie 's/id:5:initdefault:/id:3:initdefault:/g' /etc/inittab

# leave chroot
exit
