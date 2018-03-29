#!/bin/bash

MNT_PATH=/mnt/alpine
# in GiB
SIZE=1
IMG_NAME=alpine.img
PART_NAME=alpine
ROOTFS_URL=http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/alpine-minirootfs-3.7.0-x86_64.tar.gz
ROOTFS_NAME=alpine-minirootfs-3.7.0-x86_64.tar.gz

# TODO: script loop device

sudo mkdir -p $MNT_PATH
dd if=/dev/zero of=$IMG_NAME count=1024x1024x$SIZE bs=1024
sudo parted -s $IMG_NAME mklabel gpt mkpart primary ext4 0% 100% name 1 $PART_NAME
sudo losetup -v -P -f $IMG_NAME
# assumes that loop0 is the first free device in loop
sudo mke2fs -t ext4 /dev/loop0p1
sudo mount /dev/loop0p1 $MNT_PATH
cd $MNT_PATH
sudo wget $ROOTFS_URL
sudo tar -xzvf $ROOTFS_NAME ./
sudo rm $ROOTFS_NAME
cd ~/
sudo umount $MNT_PATH
sudo losetup -d /dev/loop0
