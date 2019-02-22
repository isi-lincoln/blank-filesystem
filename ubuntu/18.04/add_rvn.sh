## This script is meant to be used for baking in the raven
## user and ssh key (https://github.com/rcgoodfellow/raven)

# call this script using: 
# `sudo LANG=C.UTF-8 chroot $MNT_PATH add_raven.sh`

# set up using openssl passwd -crypt
# create a user rvn, with password rvn
useradd -s /bin/bash -m -p "QrvktB.MDe8V." rvn
# we already created the system group admin, add rvn to it
adduser rvn admin

# create a new ssh directory for the ssh keys
mkdir -p /home/rvn/.ssh/
# copy the rvn public key to rvn's authorized keys location
wget --no-check-certificate -c https://mirror.deterlab.net/rvn/rvn.pub -O /home/rvn/.ssh/authorized_keys

# we are going to overwrite network interfaces to dhcp them
cat <<'EOF' > /etc/network/interfaces
auto ens3
iface ens3 inet dhcp

auto ens4
iface ens4 inet dhcp
EOF

# wait for dhcp to come up
# systemctl disable systemd-networkd-wait-online.service

# create iamme binary
mkdir -p /iamme/
wget --no-check-certificate -c https://raw.githubusercontent.com/rcgoodfellow/raven/master/util/iamme/iamme.c -O /iamme/iamme.c
wget --no-check-certificate -c https://raw.githubusercontent.com/rcgoodfellow/raven/master/util/iamme/Makefile -O /iamme/Makefile
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

mkdir -p /etc/dhcp/
touch /etc/dhcp/dhclient.conf
sed -i 's/timeout 300/timeout 15/g' /etc/dhcp/dhclient.conf


exit
