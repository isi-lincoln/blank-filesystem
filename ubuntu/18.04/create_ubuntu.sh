#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "requires root access to build - please sudo"
   exit 1
fi

MNT_PATH=/mnt/ubuntu
# in GiB
SIZE=1

IMG_NAME=ubuntu-1804.img
PART_NAME=ubuntu
UUID_FILE=".file"

LOOP_IFACE=$(losetup -f)
echo "using loop dev: " $LOOP_IFACE

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
sudo mke2fs -t ext4 "$LOOP_IFACE"p1 > $UUID_FILE
# mount image on loop to your file system
sudo mount "$LOOP_IFACE"p1 $MNT_PATH

UUID=$(cat $UUID_FILE | grep UUID | cut -d ":" -f 2)
echo $UUID

# using debootstrap get all the necessary components for the
# file system to install at MNT_PATH
# buildd is the build-essentials variant
sudo debootstrap --arch=amd64 --variant=buildd bionic "$MNT_PATH" \
    http://archive.ubuntu.com/ubuntu

# now to actually configure the operating system call our
# helper script that will install extra modules as well
# as add additional users
sudo cp ./ubuntu_helper.sh $MNT_PATH/ubuntu_helper.sh
sudo LANG=C.UTF-8 chroot $MNT_PATH /ubuntu_helper.sh $UUID

# setup another user rvn
sudo cp ./add_rvn.sh $MNT_PATH/add_rvn.sh
sudo LANG=C.UTF-8 chroot $MNT_PATH /add_rvn.sh

## at this point i cant do anything with chroot, so copy
# ubuntu_helper script to MNT_PATH and run it to continue
# ubuntu installation
sudo umount $MNT_PATH
sudo losetup -d $LOOP_IFACE
