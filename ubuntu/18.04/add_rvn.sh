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
wget -c https://mirror.deterlab.net/rvn/rvn.pub -O /home/rvn/.ssh/authorized_keys

exit
