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

echo "Installing Dependencies"
apt install xterm -y
apt install gdb -y

chown root:root /
chown root:root /home

mkdir -p $chroot_path

echo "Creating /dev"
chroot_dev_path="$chroot_path/dev"
mkdir -p $chroot_dev_path

mknod -m 666 $chroot_dev_path/null c 1 3
mknod -m 666 $chroot_dev_path/tty c 5 0
mknod -m 666 $chroot_dev_path/zero c 1 5
mknod -m 666 $chroot_dev_path/random c 1 8
mknod -m 666 $chroot_dev_path/urandom c 1 9


chown root:root $chroot_path
chmod 755 /var/chroot

echo "Creating /bin"
chroot_bin_path="$chroot_path/bin"
mkdir -p $chroot_bin_path
cp /bin/bash $chroot_bin_path

echo "Setting up composer"
cp /usr/local/bin/composer $chroot_bin_path
cp /usr/local/bin/composer1 $chroot_bin_path
cp /usr/local/bin/composer2 $chroot_bin_path
mkdir $chroot_path/.config
cp -rf $HOME/.config/composer $chroot_path/.config/

echo "Setting WP-CLI"
## Install PHP Specific binaries
cp /usr/bin/wp $chroot_bin_path

echo "Setting NPM"
## Install Node Specific binaries
cp /usr/bin/npm $chroot_bin_path

echo "Copying Binaries (This might take a while)"
mkdir -p "$chroot_path/lib/x86_64-linux-gnu" "$chroot_path/lib64"
binaries_array=("xterm" "ls" "ln" "date" "rm" "rmdir" "mysql" "php73" "php74" "php80" "php81" "git" "wget" "curl" "nano" "stty" "grep" "find" "clear" "du" "cp" "mv" "touch" "cat" "whoami" "tee" "free" "gdb" "mkdir" "git-shell" "git-receive-pack" "git-upload-archive" "git-upload-pack" "/usr/lib/git-core/git-remote-https" "ping" "node"  "ssh" "sftp" )

for binary in ${binaries_array[@]}; do
    cp "$(which $binary)" $chroot_bin_path
    for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
    if [ -f "$lib" ] ; then
            cp --parents "$lib" "$chroot_path"
    fi  
    done
done

echo "Copying Binaries Completed!"
# cp /lib/x86_64-linux-gnu/*.so* $chroot_path/lib/x86_64-linux-gnu/
# cp /lib/*.so* $chroot_path/lib/x86_64-linux-gnu/


echo "Copying User Binaries (This might take a while)"
mkdir -p $chroot_path/usr
mkdir -p $chroot_path/usr/bin

user_binaries_array=("env")

for binary in ${user_binaries_array[@]}; do
    cp "$(which $binary)" "$chroot_path/usr/bin"

    for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
    if [ -f "$lib" ] ; then
            cp --parents "$lib" "$chroot_path"
    fi  
    done
done
echo "Copying User Binaries Completed!"

echo "Copying PHP Binaries (This might take a while)"
php_binaries_array=("php73" "php74" "php80" "php81" )

for binary in ${php_binaries_array[@]}; do    
    extension_dir=$($binary -r 'echo ini_get("extension_dir");' 2>/dev/null)
    extension_files=`ls $extension_dir | grep .so`

    for so_file in $extension_files    
    do    
        for lib in `ldd $extension_dir/$so_file | cut -d'>' -f2 | awk '{print $1}'` ; do
        if [ -f "$lib" ] ; then
                cp --parents "$lib" "$chroot_path"
        fi  
        done
    done
done
echo "Copying PHP Binaries Completed!"

echo "Setting Up DNS"
cp /lib/x86_64-linux-gnu/libnss_files.so.2 $chroot_path/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libnss_dns.so.2 $chroot_path/lib/x86_64-linux-gnu/

echo "Setting Up Git,terminfo,resolve.conf etc"
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
cp /etc/{passwd,group,resolv.conf,shadow,hosts} "$chroot_path/etc/"
cp -rf /etc/ssl $chroot_path/etc/

echo "Copying PHP Libraries!"
path_array=("/usr/lib/php" "/etc/php" )

for path in ${path_array[@]}; do
    mkdir -p "$chroot_path$path"
    cp -rf /$path/* "$chroot_path$path"    
    chmod 644 $(find "$chroot_path$path" -type f)    
done


echo "Setting up bash profiles and paths"

mkdir -p "$chroot_path/.ssh"
mkdir -p "$chroot_path/.wp-cli"

cp -rf $DIR/templates/ssh/.ssh/* "$chroot_path/.ssh" 
cp -rf $DIR/templates/ssh/.bashrc "$chroot_path/.bashrc" 
cp -rf $DIR/templates/ssh/.profile "$chroot_path/.profile" 


echo "Fixing Permissions"
chmod 755 -R "$chroot_path/usr/lib"
chmod 755 -R "$chroot_path/usr/bin"
