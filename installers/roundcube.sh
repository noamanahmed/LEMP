#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

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
    echo "Please provide a username using -u "
    exit
fi

php=8.1
username=roundcube
user_root=/opt/roundcube
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username

# Get Source Code
wget https://github.com/roundcube/roundcubemail/releases/download/1.5.2/roundcubemail-1.5.2-complete.tar.gz -O /tmp/roundcubemail-1.5.2-complete.tar.gz
tar xvf /tmp/roundcubemail-1.5.2-complete.tar.gz -C /tmp/
rm -rf $user_root
mv /tmp/roundcubemail-1.5.2-complete $user_root
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

mysql -e "CREATE DATABASE IF NOT EXISTS $database_name"
mysql -e "DROP USER IF EXISTS '$database_user'@'localhost';"
mysql -e "CREATE USER '$database_user'@'localhost' IDENTIFIED BY '$database_password'"
mysql -e "GRANT ALL PRIVILEGES ON $database_name.* To '$database_user'@'localhost'"
mysql -e "GRANT SESSION_VARIABLES_ADMIN ON *.*  TO '$database_user'@'localhost'";
mysql -e "FLUSH PRIVILEGES;"

## Setting up roundcube
nginx_vhost_file="/etc/nginx/apps-available/roundcube.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/roundcube.conf"
cp $template_path/roundcube/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

