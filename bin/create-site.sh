#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u:d:f:p flag
do
    case "${flag}" in
        u) username=${OPTARG};;        
        d) domain=${OPTARG};;
        p) php=${OPTARG};;
    esac
done

if [ -z "$username" ]
then
    echo "Please provide a username using -u "
    exit
fi


if [ -z "$domain" ]
then
    echo "Please provide a domain using -d "
    exit
fi


if [ -z "$php" ]
then
php_version="$php"
else
php_version="7.4"
fi

echo $php_version
exit

if id "$username" &>/dev/null
then
    echo "The $username already exists!. Please run delete-site -u $username"
    exit
fi

## Create system user if doesnt't exists

# $system_root="/home/$username";
# mkdir -p $system_root
# mkdir -p "$system_root/php/$php_version"


##Create user
user_password="$(openssl rand -hex 12)"

adduser --gecos "" --disabled-password $username
echo '$username:$user_password' | sudo chpasswd



## Create www path
user_root="/home/$username"
www_root="$user_root/www/"
mkdir -p $user_root
mkdir -p "$user_root/logs"
mkdir -p "$user_root/logs/nginx"
mkdir -p "$user_root/logs/php"
mkdir -p "$user_root/logs/mail"
mkdir -p $www_root
touch $www_root/index.php


## Creating PHP FPM Pool
php_versions_array=("7.3" "7.4" "8.0" "8.1")

for php_v in ${php_versions_array[@]}; do
    sudo cp /etc/php/$php_v/fpm/pool.d/template.tpl /etc/php/$php_v/fpm/pool.d/$username.conf
    sed -i "s/{{\$username}}/$username/" /etc/php/$php_v/fpm/pool.d/$username.conf
    systemctl restart php$php_v-fpm
done

## Creating nginx settings
nginx_vhost_file="/etc/nginx/sites-available/$username.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/$username.conf"
cp "$template_path/nginx/vhost.conf" $nginx_vhost_file

sed -i "s/{{www_path}}/$www_path/" $nginx_vhost_file
sed -i "s/{{domain}}/$domain/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file
sed -i "s/{{user_root}}/$user_root/" $nginx_vhost_file
sed -i "s/{{php_version}}/$php_version/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
nginx -t && systemctl reload nginx

## Fixing permissions
usermod -a -G $username nginx
chown -R $username:$username $user_root

chmod 750 $(find $user_root -type d)
chmod 640 $(find $user_root -type f)


echo "Site Created"
echo "SSH Details"
echo "Username: $username"
echo "Password: $user_password"





