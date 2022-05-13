#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

if [ "$EUID" -ne 0 ]
then echo "Please run as root"
    exit
fi

#Installing Jailkit
echo "Installing JailKit"
apt install jailkit -qqy
cp $template_path/jailkit/jk_init.ini /etc/jailkit/jk_init.ini

#Setting up JailKit
echo "Setting up JailKit"
chroot_path=/var/www/
mkdir -p $chroot_path
jk_init $chroot_path netutils extendedshell jk_lsh openvpn ssh sftp 
chroot_bin_path=$chroot_path/bin/
echo "Copying binaries for JailKit (This might take a while)"
binaries_array=("ls" "ln" "date" "rm" "rmdir" "mysql" "php56" "php70" "php71" "php72" "php73" "php74" "php80" "php81" "git" "wget" "curl" "nano" "stty" "grep" "find" "clear" "du" "cp" "mv" "touch" "cat" "whoami" "tee" "free"  "mkdir" "git-shell" "git-receive-pack" "git-upload-archive" "git-upload-pack" "/usr/lib/git-core/git-remote-https" "ping"  "ssh" "sftp" "sed" "awk" "tr" "tail" "sort" "less" "head" "cut" "egrep" "uname" "uniq" "groups" "env" "dirname" "sha256sum" "sha1sum"  "readlink" "bzip2" "sqlite3" "python2" "python3" "python310" "python35" "python36" "python37" "python38" "python39" "python27" "unzip" "basename")

for binary in ${binaries_array[@]}; do
    echo "Jaling binary $binary"
    if [ -f "$(which python$python_version)" ]
    then
        cp "$(which $binary)" $chroot_bin_path
        for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
        if [ -f "$lib" ] ; then
            jk_cp -j $chroot_path $lib                
        fi  
        done       
    fi 
done

#Fix Internet
echo "Fixing Internet for Jailed users" 
jk_cp -j $chroot_path /lib/x86_64-linux-gnu/libnss_files.so.2
jk_cp -j $chroot_path /lib/x86_64-linux-gnu/libnss_dns.so.2

echo "Copying Certificates"
jk_cp -j $chroot_path /etc/ssl/certs/ca-certificates.crt
jk_cp -j $chroot_path /usr/share/git-core

echo "Copying Locales"
cp -rf /etc/default/locale $chroot_path/etc/default/

echo "Copying Timezones"
cp -rf /usr/share/zoneinfo $chroot_path/usr/share/


echo "Copying Composer"
cp /usr/local/bin/composer $chroot_bin_path
cp /usr/local/bin/composer1 $chroot_bin_path
cp /usr/local/bin/composer2 $chroot_bin_path
cp /usr/bin/wp $chroot_bin_path
ln -s /bin/env $chroot_path/usr/bin/env

echo "Copying PIP"
cp /usr/local/bin/pip3* $chroot_bin_path
cp /usr/local/bin/pip2* $chroot_bin_path

if [ ! -f "$chroot_path/usr/bin/python2" ]
then
    ln -s ../../bin/python2 $chroot_path/usr/bin/python2
fi

if [ ! -f "$chroot_path/usr/bin/python3" ]
then
    ln -s ../../bin/python3 $chroot_path/usr/bin/python3
fi

echo "Copying Python libraries"
cp -rf /usr/lib/python* $chroot_path/usr/lib
mkdir -p $chroot_path/usr/local/lib
cp -rf /usr/local/lib/python* $chroot_path/usr/local/lib
cp -rf /usr/share/python* $chroot_path/usr/share

echo "Copying PHP Libraries"
cp -rf /usr/share/php $chroot_path/usr/share
cp -rf /usr/lib/php/ $chroot_path/usr/lib
cp -rf /etc/php/ $chroot_path/etc

echo "Copying PHP Binaries (This might take a while)"
php_binaries_array=("php56" "php70" "php71" "php72" "php73" "php74" "php80" "php81"  )

for binary in ${php_binaries_array[@]}; do    
    extension_dir=$($binary -r 'echo ini_get("extension_dir");' 2>/dev/null)
    extension_files=`ls $extension_dir | grep .so`

    for so_file in $extension_files    
    do  
        echo "Copying $so_file Libraries"  
        for lib in `ldd $extension_dir/$so_file | cut -d'>' -f2 | awk '{print $1}'` ; do
        if [ -f "$lib" ] ; then
            cp --parents "$lib" "$chroot_path"
        fi  
        done
    done
done