#!/bin/bash


if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

chroot_path=/var/chroot

if [ -d "$chroot_path" ]
then
    echo "Chroot exists as $chroot_path. First delete it!"
fi

chown root:root /
chown root:root /home

mkdir -p $chroot_path
mknod -m 666 $chroot_path/null c 1 3
mknod -m 666 $chroot_path/tty c 5 0
mknod -m 666 $chroot_path/zero c 1 5
mknod -m 666 $chroot_path/random c 1 8

chown root:root $chroot_path
chmod 755 /var/chroot

chroot_bin_path="$chroot_path/bin"
mkdir -p $chroot_bin_path

cp /bin/bash $chroot_bin_path/
cp -v /bin/ls $chroot_bin_path/bin/
cp -v /bin/date $chroot_bin_path/bin/
cp -v /bin/mkdir $chroot_bin_path/bin/

#Symbolic Links
ln -s /usr/bin/php $chroot_bin_path/bin/php
ln -s /usr/bin/git $chroot_bin_path/bin/git
ln -s /usr/bin/wget $chroot_bin_path/bin/wget
ln -s /usr/bin/composer $chroot_bin_path/bin/composer
ln -s /usr/bin/composer1 $chroot_bin_path/bin/composer1
ln -s /usr/bin/composer2 $chroot_bin_path/bin/composer2


mkdir -p "$chroot_path/lib/x86_64-linux-gnu" "$chroot_path/lib64"
cp /lib/x86_64-linux-gnu/{libtinfo.so.6,libdl.so.2,libc.so.6} "$chroot_path/lib/x86_64-linux-gnu"
cp /lib64/ld-linux-x86-64.so.2 "$chroot_path/lib64"


mkdir -p "$chroot_path/etc"
cp /etc/{passwd,group} "$chroot_path/etc/"



