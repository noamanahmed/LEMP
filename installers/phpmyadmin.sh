#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u: flag
do
    case "${flag}" in
        u) username=${OPTARG};; 
    esac
done


if [ -z "$username" ]
then
    username=$LEMP_HOSTNAME_USERNAME
fi

if ! id "$username" &>/dev/null
then
    echo "The $username doesn't exist!"
    exit
fi


php=8.1
username=phpmyadmin
password=phpmyadmin
user_root=/opt/phpmyadmin
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username
usermod -a -G $username nginx

wget https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip -O /tmp/phpmyadmin.zip
unzip -o -d /tmp/ /tmp/phpmyadmin.zip  
rm -rf $user_root
mv -f /tmp/phpMyAdmin-5.2.0-all-languages $user_root
cp -rf $template_path/phpmyadmin/* $user_root


mkdir -p $user_root/logs/
mkdir -p $user_root/tmp/
mkdir -p $user_root/logs/nginx
mkdir -p $user_root/logs/php
mkdir -p $user_root/logs/mail
mkdir -p $user_root/cache
mkdir -p $user_root/cache/nginx
chown -R $username:$username $user_root

# Setup PHP
cp $template_path/php/template.tpl /etc/php/$php/fpm/pool.d/$username.conf
sed -i "s/{{username}}/$username/" /etc/php/$php/fpm/pool.d/$username.conf
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/" /etc/php/$php/fpm/pool.d/$username.conf
systemctl restart php$php-fpm

## Creating MYSQL user and database
# Skipped PHPMyAdmin doesn't need a specific database for itself
# database_name="$(echo $username | head -c 12)"
# database_user="$(echo $username | head -c 12)"
# database_password="$(openssl rand -hex 8)"

# mysql -e "DROP DATABASE IF EXISTS $username"
# mysql -e "DROP USER IF EXISTS '$username'@'localhost';"
# mysql -e "CREATE DATABASE IF NOT EXISTS $database_name"
# mysql -e "DROP USER IF EXISTS '$database_user'@'localhost';"
# mysql -e "CREATE USER '$database_user'@'localhost' IDENTIFIED BY '$database_password'"
# mysql -e "GRANT ALL PRIVILEGES ON $database_name.* To '$database_user'@'localhost'"
# mysql -e "GRANT SESSION_VARIABLES_ADMIN ON *.*  TO '$database_user'@'localhost'";
# mysql -e "FLUSH PRIVILEGES;"


fix-permissions -u $username

## Setting up phpmyadmin admin
nginx_vhost_file="/etc/nginx/apps-available/phpmyadmin.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/phpmyadmin.conf"
cp $template_path/phpmyadmin/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file
sed -i "s/{{www_path}}/$(echo $user_root/public | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

