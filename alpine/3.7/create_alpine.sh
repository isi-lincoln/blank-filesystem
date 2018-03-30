#!/bin/bash

MNT_PATH=/mnt/alpine
# in GiB
SIZE=1

IMG_NAME=alpine.img
PART_NAME=alpine

ROOTFS_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/alpine-minirootfs-3.7.0-x86_64.tar.gz
ROOTFS_NAME=alpine-minirootfs-3.7.0-x86_64.tar.gz

LOOP_IFACE=/dev/loop0

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
# move to directory, download alpine filesystem, untar it
cd $MNT_PATH
sudo wget $ROOTFS_URL
sudo tar -xzvf $ROOTFS_NAME ./
sudo rm $ROOTFS_NAME
cd ~/
# unmount the directory
sudo umount $MNT_PATH
# unmount the image from loop
sudo losetup -d $LOOP_IFACE
