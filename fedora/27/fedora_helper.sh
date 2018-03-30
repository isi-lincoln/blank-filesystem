# in chroot environment - prepare the filesystem for use
dnf install -y \
iputils \
sudo \
kexec-tools \
wget \
vim

# TODO: note there is no root partition in fstab
# would like to get uuid from parted and pass that in here
# as the root partition

cat <<'EOF' > /etc/fstab
proc             /proc         proc    defaults                 0    0
sys              /sys          sysfs   defaults                 0    0
EOF

useradd -s /bin/bash -m -p "e/CBifV4.zT.6" test
echo "test ALL=(ALL) ALL" >> /etc/sudoers

# dont let the sucker try and boot into graphical
systemctl set-default multi-user.target
rm /etc/systemd/system/default.target
ln -s /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target

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

# leave chroot
exit
