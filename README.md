# Blank Filesystems

The purpose of this repo is to enable other users to generate blank filesystems.
What I mean by that is filesystems that are not polluted with excess junk such
as unwanted packages, distro artifacts, etc.  These blank filesystems are useful
in situations where the purpose is to seperate the filesystem with the kernel
and initramfs.  For example running 4.10 vs 4.12 kernels.  Or Xenial vs Biotic
(ubuntu).

Blank-filesystems was created for use with
[sled](https://github.com/ceftb/sled).  Sled allows for quick swaping of
kernels, and as necessary filesystems as well.  Based on using
[u-root](https://github.com/u-root/u-root) with kexec to jump from one kernel
image to another.  With that being said, you may find some weirdness which
relates to kexec, or serial configurations which is directly to do with sled,
but which you may comfortable comment out or ignore.


## Creating a blank filesystem

Each filesystem lives under the directory based on distro and release. In each
directory there should be a `create_*.sh` script which you can call to create
the desired filesystem.  Some scripts will have helper scripts which will
create additional users, modify locale, or serial settings to work effectively
with sled.


## Using a blank filesystem

Here are some of the settings that I use when booting my ubuntu-1604 filesystem

```
console=ttyS0 qemu-system-x86_64 -kernel vmlinuz-4.15.0-ubuntu  -initrd initramfs-ubuntu.cpio -append "console=ttyS0 root=/dev/sda1" -drive file=mini-ubuntu.img,media=disk,format=raw,if=ide -serial mon:stdio -m 1024
```

`console=ttyS0` is setting the console environment variable to be `ttyS0` for
qemu.

`-kernel vmlinuz-4.15.0-ubuntu` specifies the kernel I have previous built and
would like to use.

`-initrd initramfs-ubuntu.cpio` is the initramfs to be loaded

`-append "console=ttyS0 root=/dev/sda1"` specifies the kernel options to be
loaded.  In this case we specify again that the console should be sent to
`ttyS0` (the terminal), and that the root filesystem is specified at
`/dev/sda1`.  This is based on when you build the filesystem if you choose
to add/change/modify the partition layout of where the root filesystem
is located.  By default in the scripts below, it is `/dev/sda1`.

`-drive file=mini-ubuntu.img,media=disk,format=raw,if=ide` tells qemu that we wish
to load the `mini-ubuntu.img` as a disk.  It being the first one, it will be `/dev/sda1`
as we called it from the above append command.

`-serial mon:stdio` uses are terminal (`ttyS0`) as the serial interface to communicate
via stdio.  The mon prefix is for handling certain signals, such as ctrl-c to be passed
to the guest rather than handled by qemu.

`-m 1024` depending on the initramfs, or if you are using kexec are need to load the new
initramfs into memory (depending on the size), may be necessary to have 1GB of memory.
Generally, if you have lightweight initramfs, you should be fine leaving this off and
using qemu's default 128MB.


#### Resources:

https://help.ubuntu.com/lts/installation-guide/powerpc/apds04.html
