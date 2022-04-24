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
chroot_path=/var/chroot/
mkdir -p $chroot_path
jk_init $chroot_path netutils extendedshell jk_lsh openvpn ssh sftp 
chroot_bin_path=$chroot_path/bin/
echo "Copying binaries for JailKit"
binaries_array=("xterm" "ls" "ln" "date" "rm" "rmdir" "mysql" "php56" "php70" "php71" "php72" "php73" "php74" "php80" "php81" "git" "wget" "curl" "nano" "stty" "grep" "find" "clear" "du" "cp" "mv" "touch" "cat" "whoami" "tee" "free" "gdb" "mkdir" "git-shell" "git-receive-pack" "git-upload-archive" "git-upload-pack" "/usr/lib/git-core/git-remote-https" "ping"  "ssh" "sftp" "sed" "awk" "tr" "tail" "sort" "less" "head" "cut" "egrep" "uname" "uniq" "groups")

for binary in ${binaries_array[@]}; do
    cp "$(which $binary)" $chroot_bin_path
    for lib in `ldd "$(which $binary)" | cut -d'>' -f2 | awk '{print $1}'` ; do
    if [ -f "$lib" ] ; then
        jk_cp -j $chroot_path $lib                
    fi  
    done        
done

#Fix Internet
echo "Fixing Internet for Jailed users" 

jk_cp -v -j $chroot_path /lib/x86_64-linux-gnu/libnss_files.so.2
jk_cp -v -j $chroot_path /lib/x86_64-linux-gnu/libnss_dns.so.2

cp /usr/local/bin/composer $chroot_bin_path
cp /usr/local/bin/composer1 $chroot_bin_path
cp /usr/local/bin/composer2 $chroot_bin_path
cp /usr/bin/wp $chroot_bin_path

mkdir -p $chroot_path/.ssh
mkdir -p $chroot_path/.wp-cli


cp -rf $template_path/jailed_ssh/.ssh/* "$chroot_path/.ssh" 
cp -rf $template_path/jailed_ssh/.bashrc "$chroot_path/.bashrc" 
cp -rf $template_path/jailed_ssh/.profile "$chroot_path/.profile" 
