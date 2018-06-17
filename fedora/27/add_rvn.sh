## This script is meant to be used for baking in the raven
## user and ssh key (https://github.com/rcgoodfellow/raven)

# call this script using: 
# `sudo LANG=C.UTF-8 chroot $MNT_PATH add_raven.sh`

# set up using openssl passwd -crypt
# create a user rvn, with password rvn
adduser -s /bin/bash -m -p "QrvktB.MDe8V." rvn
# we already created the system group admin, add rvn to it
usermod -G admin rvn

# create a new ssh directory for the ssh keys
mkdir -p /home/rvn/.ssh/
# copy the rvn public key to rvn's authorized keys location
wget -c https://mirror.deterlab.net/rvn/rvn.pub -O /home/rvn/.ssh/authorized_keys

# we are going to overwrite network interfaces to dhcp them
cat <<'EOF' > /etc/sysconfig/network-scripts/ifcfg-eno1
DEVICE=eno1
BOOTPROTO=dhcp
ONBOOT=yes
EOF
cat <<'EOF' > /etc/sysconfig/network-scripts/ifcfg-eno2
DEVICE=eno2
BOOTPROTO=dhcp
ONBOOT=yes
EOF

# wait for dhcp to come up
# systemctl disable systemd-networkd-wait-online.service

# create iamme binary
mkdir -p /iamme/
wget -c https://raw.githubusercontent.com/rcgoodfellow/raven/master/util/iamme/iamme.c -O /iamme/iamme.c
wget -c https://raw.githubusercontent.com/rcgoodfellow/raven/master/util/iamme/Makefile -O /iamme/Makefile
cd /iamme/ && make

cat <<'EOF' > /etc/systemd/system/iamme.service
[Unit]
Description=Make sure dhcp address is registered with raven

[Service]
Type=simple
RemainAfterExit=no
Environment=IFACE='ens3' DHCP_SERV='172.22.0.1'
ExecStart=/iamme/iamme $IFACE $DHCP_SERV

[Install]
WantedBy=multi-user.target
EOF

exit
