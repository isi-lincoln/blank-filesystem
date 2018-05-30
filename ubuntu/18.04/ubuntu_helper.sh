# in chroot environment - prepare the filesystem for use
apt-get update
apt-get install -y makedev
mount none /proc -t proc
cd /dev
MAKEDEV generic
umount /proc

# TODO: note there is no root partition in fstab
# would like to get uuid from parted and pass that in here
# as the root partition

cat <<'EOF' > /etc/fstab
proc             /proc         proc    defaults                 0    0
sys              /sys          sysfs   defaults                 0    0
EOF

cd /

# set up time/locale
cat <<'EOF' > /tzdata.conf
tzdata tzdata/Areas select US
tzdata tzdata/Zones/US select Pacific
EOF
debconf-set-selections /tzdata.conf
rm /etc/timezone
rm /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# add security and source to deb list
cat <<'EOF' > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu bionic main
deb-src http://archive.ubuntu.com/ubuntu bionic main
deb http://security.ubuntu.com/ubuntu bionic-security main
deb-src http://security.ubuntu.com/ubuntu bionic-security main
EOF

# refresh the deb lists
apt-get update


# most annoying part is setting up keyboard
# necessary if you dont want to deal with dead-keys
cat <<'EOF' > /keyboard.txt
keyboard-configuration  console-setup/detected  note    
d-i keyboard-configuration/unsupported_options  boolean true
keyboard-configuration  keyboard-configuration/unsupported_options  boolean true
d-i keyboard-configuration/ctrl_alt_bksp    boolean false
keyboard-configuration  keyboard-configuration/ctrl_alt_bksp    boolean false
d-i keyboard-configuration/variant  select  English (US)
keyboard-configuration  keyboard-configuration/variant  select  English (US)
# keyboard-configuration  console-setup/detect    detect-keyboard 
keyboard-configuration  console-setup/ask_detect    boolean false
d-i keyboard-configuration/layoutcode   string  us
keyboard-configuration  keyboard-configuration/layoutcode   string  us
d-i keyboard-configuration/xkb-keymap   select  
keyboard-configuration  keyboard-configuration/xkb-keymap   select  
d-i keyboard-configuration/optionscode  string  
keyboard-configuration  keyboard-configuration/optionscode  string  
d-i keyboard-configuration/modelcode    string  pc105
keyboard-configuration  keyboard-configuration/modelcode    string  pc105
d-i keyboard-configuration/variantcode  string  
keyboard-configuration  keyboard-configuration/variantcode  string  
d-i keyboard-configuration/unsupported_layout   boolean true
keyboard-configuration  keyboard-configuration/unsupported_layout   boolean true
d-i keyboard-configuration/compose  select  No compose key
keyboard-configuration  keyboard-configuration/compose  select  No compose key
d-i keyboard-configuration/toggle   select  No toggling
keyboard-configuration  keyboard-configuration/toggle   select  No toggling
d-i keyboard-configuration/model    select  Generic 105-key (Intl) PC
keyboard-configuration  keyboard-configuration/model    select  Generic 105-key (Intl) PC
d-i keyboard-configuration/unsupported_config_layout    boolean true
keyboard-configuration  keyboard-configuration/unsupported_config_layout    boolean true
d-i keyboard-configuration/switch   select  No temporary switch
keyboard-configuration  keyboard-configuration/switch   select  No temporary switch
d-i keyboard-configuration/altgr    select  The default for the keyboard layout
keyboard-configuration  keyboard-configuration/altgr    select  The default for the keyboard layout
d-i keyboard-configuration/store_defaults_in_debconf_db boolean true
keyboard-configuration  keyboard-configuration/store_defaults_in_debconf_db boolean true
d-i keyboard-configuration/layout   select  English (US)
keyboard-configuration  keyboard-configuration/layout   select  English (US)
d-i keyboard-configuration/unsupported_config_options   boolean true
keyboard-configuration  keyboard-configuration/unsupported_config_options   boolean true
EOF

debconf-set-selections /keyboard.txt
dpkg-reconfigure -f noninteractive keyboard-configuration

# install sudo before we mess with sudoers
apt-get install -qy sudo

# set up using openssl passwd -crypt
# username: test, password: test
useradd -s /bin/bash -m -p "e/CBifV4.zT.6" test
addgroup --system admin
adduser test admin
echo "admin ALL=(ALL) ALL" >> /etc/sudoers

# kexec-tools is unnecessary for most people - comment out as needed
DEBIAN_FRONTEND=noninteractive apt-get -yq install kexec-tools

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
less

# dont let the sucker try and boot into graphical
systemctl set-default multi-user.target

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
