#!/bin/bash

# stop execution on failure
set -e

MNT_PATH=/mnt/fedora
# in GiB
SIZE=2

RELEASE=29
IMG_NAME=fedora-$RELEASE.img
PART_NAME=fedora

LOOP_IFACE=$(sudo losetup -f)

# create the directory to mount to
sudo mkdir -p $MNT_PATH
# allocate space for the alpine image to use
dd if=/dev/zero of=$IMG_NAME count=1024x1024x$SIZE bs=1024
# partition the alpine image with a single ext4 parition
sudo parted -s $IMG_NAME \
    mklabel gpt mkpart primary ext4 0% 100% \
    name 1 $PART_NAME
# mount the image to the loop interface
sudo losetup -v -P $LOOP_IFACE $IMG_NAME
# create the partition type, i've found parted doesnt set ext4
sudo mke2fs -t ext4 "$LOOP_IFACE"p1
# mount image on loop to your file system
sudo mount "$LOOP_IFACE"p1 $MNT_PATH

# https://geek.co.il/2010/03/14/how-to-build-a-chroot-jail-environment-for-centos
FEDORA=fedora-release-$RELEASE-1.noarch.rpm
sudo mkdir -p $MNT_PATH/var/lib/rpm
sudo rpm --rebuilddb --root=$MNT_PATH
wget https://dl.fedoraproject.org/pub/fedora/linux/releases/$RELEASE/Everything/x86_64/os/Packages/f/$FEDORA
sudo rpm -i --root=$MNT_PATH --nodeps $FEDORA
sudo yum --releasever=$RELEASE --nogpgcheck --installroot=$MNT_PATH install -y yum dnf net-tools kexec-tools wget make gcc
rm $FEDORA

sudo cp ./repos/yum.conf $MNT_PATH/etc/yum.conf
sudo cp ./repos/fedora*.repo $MNT_PATH/etc/yum.repos.d/
sudo cp ./repos/vars/releasever $MNT_PATH/etc/yum/vars/

# now to actually configure the operating system call our
# helper script that will install extra modules as well
# as add additional users
sudo cp ./fedora_helper.sh $MNT_PATH/fedora_helper.sh
sudo LANG=C.UTF-8 chroot $MNT_PATH /fedora_helper.sh

sudo cp ./add_rvn.sh $MNT_PATH/add_rvn.sh
sudo LANG=C.UTF-8 chroot $MNT_PATH /add_rvn.sh
## at this point i cant do anything with chroot, so copy
# fedora_helper script to MNT_PATH and run it to continue
# fedora installation
sudo umount $MNT_PATH
sudo losetup -d $LOOP_IFACE
