#!/bin/bash
MNT_PATH=/mnt/fedora
# in GiB
SIZE=1

IMG_NAME=fedora-27.img
PART_NAME=fedora

LOOP_IFACE=/dev/loop0

HERE=$(pwd)

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


cd $MNT_PATH
# from https://nmilosev.svbtle.com/quick-and-easy-fedora-minimal-chroot
sudo wget http://mirror.cs.pitt.edu/fedora/linux/releases/27/Docker/x86_64/images/Fedora-Docker-Base-27-1.6.x86_64.tar.xz

sudo tar xvf Fedora-Docker-Base-27-1.6.x86_64.tar.xz --strip-components=1
sudo tar xvpf layer.tar
sudo rm layer.tar
sudo rm Fedora-Docker-Base-27-1.6.x86_64.tar.xz
sudo rm json
sudo rm VERSION

cd $HERE

# now to actually configure the operating system call our
# helper script that will install extra modules as well
# as add additional users
sudo cp ./fedora_helper.sh $MNT_PATH/fedora_helper.sh
sudo LANG=C.UTF-8 chroot $MNT_PATH /fedora_helper.sh

## at this point i cant do anything with chroot, so copy
# fedora_helper script to MNT_PATH and run it to continue
# fedora installation
sudo umount $MNT_PATH
sudo losetup -d $LOOP_IFACE
