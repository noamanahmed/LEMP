#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

php=8.1
username=roundcube
user_root=/opt/roundcube
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username
usermod -a -G $username nginx

# Get Source Code
wget https://github.com/roundcube/roundcubemail/releases/download/1.5.2/roundcubemail-1.5.2-complete.tar.gz -O /tmp/roundcubemail-1.5.2-complete.tar.gz
tar xf /tmp/roundcubemail-1.5.2-complete.tar.gz -C /tmp/
rm -rf $user_root
mv /tmp/roundcubemail-1.5.2 $user_root
cp $template_path/roundcube/config.inc.php $user_root/config/

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
database_name="$(echo $username | head -c 12)"
database_user="$(echo $username | head -c 12)"
database_password="$(openssl rand -hex 8)"

mysql -e "DROP DATABASE IF EXISTS $username"
mysql -e "DROP USER IF EXISTS '$username'@'localhost';"
mysql -e "CREATE DATABASE IF NOT EXISTS $database_name"
mysql -e "DROP USER IF EXISTS '$database_user'@'localhost';"
mysql -e "CREATE USER '$database_user'@'localhost' IDENTIFIED BY '$database_password'"
mysql -e "GRANT ALL PRIVILEGES ON $database_name.* To '$database_user'@'localhost'"
mysql -e "GRANT SESSION_VARIABLES_ADMIN ON *.*  TO '$database_user'@'localhost'";
mysql -e "FLUSH PRIVILEGES;"

pv $template_path/roundcube/mysql.sql  | mysql -u root $username


sed -i "s/{{domain}}/$HOSTNAME/"  $user_root/config/config.inc.php
sed -i "s/{{db_name}}/$database_name/"  $user_root/config/config.inc.php
sed -i "s/{{db_username}}/$database_user/"  $user_root/config/config.inc.php
sed -i "s/{{db_password}}/$database_password/"  $user_root/config/config.inc.php
sed -i "s/{{hash_key}}/$(openssl rand -hex 16)/"  $user_root/config/config.inc.php

## Setting up roundcube
nginx_vhost_file="/etc/nginx/apps-available/roundcube.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/roundcube.conf"
cp $template_path/roundcube/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file
sed -i "s/{{www_path}}/$(echo $user_root | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

touch $LEMP_FLAG_DIR/ROUNDCUBE_INSTALLED
