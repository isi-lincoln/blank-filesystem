# Creating an alpine filesystem

Creating an alpine filesystem is a bit challenging for me as I am not yet
fully comfortable with the operating system.  The filesystem however is
taken from their website.  My understanding is that it is based on the
hardened kernel.  So if you try using the vanilla or a custom kernel,
you will get a kernel panic specifying that `/dev/sda1` is unable to be
mounted to `/sysroot`.  I have not yet found a means to rectify this. Instead
I make sure to use a hardened kernel/initramfs.

Alpine 3.7 downloads can be found
[here](http://dl-cdn.alpinelinux.org/alpine/v3.7/releases/x86_64/).


## Building the filesystem


Pretty straight forward, `sudo create_alpine.sh`.  The script currently makes
the assumption that `/dev/loop0` is free to use.  If you want to create a
larger/smaller image than the default 1GB, you can modify the `SIZE value.


The default user is `root` with no password.
