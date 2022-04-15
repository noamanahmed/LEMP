#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

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
apt install gdb -y

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

binaries_array=("xterm" "ls" "date" "rm" "rmdir" "php" "php73" "php74" "php80" "php81" "wp" "git" "wget" "curl" "composer" "composer1" "composer2" "nano" "stty" "grep" "find" "clear" "du" "cp" "mv" "touch" "cat" "whoami" "tee" "free" "gdb" "mkdir" "git-shell" "git-receive-pack" "git-upload-archive" "git-upload-pack" "ping")

for binary in ${binaries_array[@]}; do
    cp -v "$(which $binary)" $chroot_bin_path

    for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
    if [ -f "$lib" ] ; then
            cp -v --parents "$lib" "$chroot_path"
    fi  
    done
done

cp /lib/x86_64-linux-gnu/*.so* $chroot_path/lib/x86_64-linux-gnu/
cp /lib/*.so* $chroot_path/lib/x86_64-linux-gnu/

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

mkdir -p $chroot_path/usr/lib/git-core/
cp -rf /usr/lib/git-core/* $chroot_path/usr/lib/git-core/

mkdir -p $chroot_path/usr/share
mkdir -p $chroot_path/usr/share/terminfo
mkdir -p $chroot_path/usr/share/zoneinfo
mkdir -p $chroot_path/usr/share/git-core

cp -rf /usr/share/terminfo/* $chroot_path/usr/share/terminfo/
cp -rf /usr/share/zoneinfo/* $chroot_path/usr/share/zoneinfo/
cp -rf /usr/share/git-core/* $chroot_path/usr/share/git-core/

mkdir -p $chroot_path/lib
mkdir -p $chroot_path/lib/terminfo
cp -rf /lib/terminfo/* $chroot_path/lib/terminfo/
mkdir -p "$chroot_path/etc"
cp /etc/{passwd,group,resolv.conf} "$chroot_path/etc/"
cp -rf /etc/ssl $chroot_path/etc/


path_array=("/usr/lib/php" "/etc/php" )

for path in ${path_array[@]}; do
    mkdir -p "$chroot_path$path"
    cp -rf /$path/* "$chroot_path$path"    
    chmod 644 $(find "$chroot_path$path" -type f)    
done



chmod 755 -R "$chroot_path/usr/lib"
chmod 755 -R "$chroot_path/usr/bin"


mkdir -p "$chroot_path/.ssh"
cp -rf $DIR/templates/ssh/.ssh/* "$chroot_path/.ssh" 
cp -rf $DIR/templates/ssh/.bashrc "$chroot_path/.bashrc" 
cp -rf $DIR/templates/ssh/.profile "$chroot_path/.profile" 


