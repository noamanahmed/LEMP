#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u:d:p: flag
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
php_version="7.4"
else
php_version=$php
fi


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

## Uncomment the following user to allow jailed user access
usermod -a -G web $username
usermod -a -G sftp $username


## Create www path
user_root="/home/$username"
www_path="$user_root/www"
mkdir -p $user_root
mkdir -p "$user_root/logs"
mkdir -p "$user_root/logs/nginx"
mkdir -p "$user_root/logs/php"
mkdir -p "$user_root/logs/mail"
mkdir -p $www_path
cp "$template_path/www/*" $www_path

## Setting up for jailed user
chown root:root /
chown root:root /home
chown root:root /home/$username
chown 755  /home/$username
bash jail-user.sh -u $username

## Creating PHP FPM Pool
php_versions_array=("7.3" "7.4" "8.0" "8.1")

for php_v in ${php_versions_array[@]}; do
    sudo cp /etc/php/$php_v/fpm/pool.d/template.tpl /etc/php/$php_v/fpm/pool.d/$username.conf
    sed -i "s/{{\$username}}/$username/" /etc/php/$php_v/fpm/pool.d/$username.conf
    systemctl restart php$php_v-fpm
done

## Creating mysql user and database

database_name="$(echo $username)"
database_user="$(echo $username)"
database_password="$(echo $username)_$(openssl rand -hex 12)"

mysql -ve "CREATE DATABASE IF NOT EXISTS $database_name"
mysql -ve "CREATE USER '$database_user'@'localhost' IDENTIFIED BY '$database_password'"
mysql -ve "GRANT ALL PRIVILEGES ON $database_name.* To '$database_user'@'localhost'"
mysql -ve "GRANT SESSION_VARIABLES_ADMIN ON *.*  TO '$database_user'@'localhost'";
mysql -ve "FLUSH PRIVILEGES;"


## Creating nginx settings
nginx_vhost_file="/etc/nginx/sites-available/$username.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/$username.conf"
cp "$template_path/nginx/vhost.conf" $nginx_vhost_file

sed -i "s/{{www_path}}/$(echo $www_path | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{domain}}/$domain/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{php_version}}/$php_version/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
nginx -t && systemctl reload nginx

certbot certonly --webroot -d $domain --non-interactive --agree-tos -m noamanahmed99@gmail.com -w $www_path

## Setting SSL nginx settings
nginx_vhost_file="/etc/nginx/sites-available/$username-ssl.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/$username-ssl.conf"
cp "$template_path/nginx/vhost-ssl.conf" $nginx_vhost_file

sed -i "s/{{www_path}}/$(echo $www_path | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{domain}}/$domain/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{php_version}}/$php_version/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
nginx -t && systemctl reload nginx

## Fixing permissions
usermod -a -G $username nginx
chown -R $username:$username $user_root/*
chown -R $username:$username $user_root/.*

chmod 750 $(find $user_root -type d)
chmod 640 $(find $user_root -type f)

echo "*****************************************"
echo "*****************************************"
echo ""
echo "Site Setup succssfull"
echo "URL : http://$domain"
echo "URL(SSL) : https://$domain"
echo "Complete Path : $www_path"
echo ""
echo "Database Credentials"
echo "Database name: $database_name"
echo "Database user: $database_user"
echo "Database password: $database_password"
echo ""
echo "SFTP/SSH Details"
echo "Username: $username"
echo "Password: $user_password"





