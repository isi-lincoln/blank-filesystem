# Creating an ubuntu 18.04 filesystem


The ubuntu filesystem creation looks similiar to other methods with the
distinction that after it mounts the partitions it calls `debootstrap`.
[debootstrap](https://wiki.debian.org/Debootstrap) to populate the filesystem.

After installing all of the necessary debian files, it `chroot`s calling the
`ubuntu_helper.sh` script.  Which populates device drivers, adds proc and sys
to fstab (note that the root partition will need to be passed in as a kernel
argument).  Future work is to use the UUID from blkid to correctly mount the
from fstab without the kernel argument.  Nex the script modifies the locales
to be west coast / us time, updates the debian package lists, *attempts* to
configure the keyboard to `us` (currently doesnt work as intended), adds a
user `test` with password `test` to sudoers, installs `kexec-tools` for
[sled](https://github.com/ceftb/sled), followed by a list of somewhat essential
packages.

The last bit of the `ubuntu_helper.sh` works towards getting the filesystem
to work with only a serial interface. `systemctl set-default multi-user.target`
disables graphical mode. Followed by creating an agetty service: 
`/etc/systemd/system/getty.target.wants/getty\@ttyS1.service` for ttyS1.
Note that on the main README it uses `ttyS0`.  Sled is built off
[raven](https://github.com/rcgoodfellow/raven) which defaults the serial
interface to be ttyS1 unless otherwise specified.  Within the agetty
configuration file are links to agetty resources for further modification.
Lastly, the helper scripts exits, and the `create_ubuntu.sh` takes back over
umounting the partition and disconnecting loop0.

## Building the filesystem

As before: `create_ubuntu..sh`

You may find if you are building on Ubuntu, that you will need to install
`debootstrap`
