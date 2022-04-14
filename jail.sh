#!/bin/bash


if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

chroot_path=/var/chroot

if [ -d "/path/to/dir" ]
then
    echo "Chroot exists as $chroot_path. First delete it!"
fi
mkdir -p $chroot_path
mknod -m 666 $chroot_path/null c 1 3
mknod -m 666 $chroot_path/tty c 5 0
mknod -m 666 $chroot_path/zero c 1 5
mknod -m 666 $chroot_path/random c 1 8

chown root:root $chroot_path
chmod 755 /var/chroot

chroot_bin_path="$chroot_path/bin"

cp /bin/bash $chroot_bin_path

mkdir -p "$chroot_path/lib/x86_64-linux-gnu" "$chroot_path/lib64"
cp /lib/x86_64-linux-gnu/{libtinfo.so.6,libdl.so.2,libc.so.6} "$chroot_path/lib/x86_64-linux-gnu"
cp /lib64/ld-linux-x86-64.so.2 "$chroot_path/lib64"


mkdir -p "$chroot_path/etc"
cp /etc/{passwd,group} "$chroot/etc"



