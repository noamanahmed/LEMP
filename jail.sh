#!/bin/bash


if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

chroot_path=/var/chroot

if [ -d "$chroot_path" ]
then
    echo "Chroot exists as $chroot_path. First delete it!"
    exit
fi

apt install xterm -y

chown root:root /
chown root:root /home

mkdir -p $chroot_path

chroot_dev_path="$chroot_path/dev"
mkdir -p $chroot_dev_path

mknod -m 666 $chroot_dev_path/null c 1 3
mknod -m 666 $chroot_dev_path/tty c 5 0
mknod -m 666 $chroot_dev_path/zero c 1 5
mknod -m 666 $chroot_dev_path/random c 1 8


chown root:root $chroot_path
chmod 755 /var/chroot

chroot_bin_path="$chroot_path/bin"
mkdir -p $chroot_bin_path

cp -v /bin/bash $chroot_bin_path
cp -v /usr/local/bin/composer $chroot_bin_path
cp -v /usr/local/bin/composer1 $chroot_bin_path
cp -v /usr/local/bin/composer2 $chroot_bin_path

mkdir -p "$chroot_path/lib/x86_64-linux-gnu" "$chroot_path/lib64"
cp /lib/x86_64-linux-gnu/{libtinfo.so.6,libdl.so.2,libc.so.6,libselinux.so.1} "$chroot_path/lib/x86_64-linux-gnu"
cp /lib64/ld-linux-x86-64.so.2 "$chroot_path/lib64"
cp /lib/x86_64-linux-gnu/{libselinux.so.1,libcap.so.2,libacl.so.1,libc.so.6,libpcre2-8.so.0,libdl.so.2,ld-linux-x86-64.so.2,libattr.so.1,libpthread.so.0} "$chroot_path/lib/x86_64-linux-gnu"

binaries_array=("xterm" "ls" "date" "rm" "rmdir" "php" "wp" "git" "wget" "composer" "composer1" "composer2" "nano" "stty" "grep" "find" "clear")

for binary in ${binaries_array[@]}; do
    cp -v "$(which $binary)" $chroot_bin_path

    for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
    if [ -f "$lib" ] ; then
            cp -v --parents "$lib" "$chroot_path"
    fi  
    done
done

mkdir -p $chroot_path/usr
mkdir -p $chroot_path/usr/bin

user_binaries_array=("env")

for binary in ${user_binaries_array[@]}; do
    cp -v "$(which $binary)" "$chroot_path/usr/bin"

    for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
    if [ -f "$lib" ] ; then
            cp -v --parents "$lib" "$chroot_path"
    fi  
    done
done



mkdir -p $chroot_path/usr/share
mkdir -p $chroot_path/usr/share/terminfo
cp -rf /usr/share/terminfo/* $chroot_path/usr/share/terminfo/
mkdir -p $chroot_path/lib
mkdir -p $chroot_path/lib/terminfo
cp -rf /lib/terminfo/* $chroot_path/lib/terminfo/
mkdir -p "$chroot_path/etc"
cp /etc/{passwd,group} "$chroot_path/etc/"


 ln -s  /etc/php/ "$chroot_path/etc/php"
