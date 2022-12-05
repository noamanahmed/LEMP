#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

php=8.1
username=postfixadmin
password=postfixadmin
user_root=/opt/postfixadmin
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username
usermod -a -G $username nginx
usermod -a -G dovecot $username
# Get Source Code
wget https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-3.3.11.tar.gz -O /tmp/postfixadmin-3.3.11.tar.gz
tar xf /tmp/postfixadmin-3.3.11.tar.gz -C /tmp/
rm -rf $user_root
mv /tmp/postfixadmin-postfixadmin-3.3.11 $user_root
#COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --working-dir=$user_root
cp $template_path/postfixadmin/config.local.php $user_root/
mkdir -p $user_root/templates_c/


mkdir -p $user_root/logs/
mkdir -p $user_root/tmp/
mkdir -p $user_root/logs/nginx
mkdir -p $user_root/logs/php
mkdir -p $user_root/logs/mail
mkdir -p $user_root/cache
mkdir -p $user_root/cache/nginx
chown -R $username:$username $user_root

# Setup PHP
cp $template_path/postfixadmin/php.conf /etc/php/$php/fpm/pool.d/$username.conf
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


hash_password=$(php  -r "echo password_hash('$password', PASSWORD_ARGON2I);")

cp $template_path/postfixadmin/mysql.sql /tmp/mysql-postfixadmin.sql
sed -i "s/{{domain}}/$HOSTNAME/g" /tmp/mysql-postfixadmin.sql
sed -i "s/{{username}}/$username/g" /tmp/mysql-postfixadmin.sql
sed -i "s/{{password}}/$(echo $hash_password | sed 's/\//\\\//g')/" /tmp/mysql-postfixadmin.sql


pv /tmp/mysql-postfixadmin.sql  | mysql -u root $username



## Setting up postfix admin
nginx_vhost_file="/etc/nginx/apps-available/postfixadmin.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/postfixadmin.conf"
cp $template_path/postfixadmin/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file
sed -i "s/{{username}}/$username/" $nginx_vhost_file
sed -i "s/{{www_path}}/$(echo $user_root/public | sed 's/\//\\\//g')/" $nginx_vhost_file
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

## We needed to setup SQL for proper postfix configuration
cp $template_path/postfix/master.cf /etc/postfix/master.cf
cp $template_path/postfix/main.cf /etc/postfix/main.cf
sed -i "s/{{domain}}/$HOSTNAME/" /etc/postfix/main.cf


mkdir -p /etc/postfix/sql/
cp -rf $template_path/postfix/sql/* /etc/postfix/sql/
chmod -R 0640 /etc/postfix/sql/*
chown -R postfix:postfix /etc/postfix/sql

sql_files_array=( "mysql_virtual_alias_domain_catchall_maps.cf" "mysql_virtual_alias_domain_mailbox_maps.cf" "mysql_virtual_alias_domain_maps.cf" "mysql_virtual_alias_maps.cf" "mysql_virtual_domains_maps.cf" "mysql_virtual_mailbox_maps.cf" )

for sql_file in ${sql_files_array[@]}; do
    sed -i "s/{{db_name}}/$database_name/" /etc/postfix/sql/$sql_file
    sed -i "s/{{db_username}}/$database_user/" /etc/postfix/sql/$sql_file
    sed -i "s/{{db_password}}/$database_password/" /etc/postfix/sql/$sql_file
done

sed -i "s/{{db_name}}/$database_name/" /etc/postfix/main.cf
sed -i "s/{{db_username}}/$database_user/" /etc/postfix/main.cf
sed -i "s/{{db_password}}/$database_password/" /etc/postfix/main.cf


sed -i "s/{{db_name}}/$database_name/"  /$user_root/config.local.php
sed -i "s/{{db_username}}/$database_user/"  /$user_root/config.local.php
sed -i "s/{{db_password}}/$database_password/"  /$user_root/config.local.php


sed -i "s/{{db_name}}/$database_name/" /etc/dovecot/dovecot-sql.conf.ext
sed -i "s/{{db_username}}/$database_user/" /etc/dovecot/dovecot-sql.conf.ext
sed -i "s/{{db_password}}/$database_password/" /etc/dovecot/dovecot-sql.conf.ext
sed -i "s/{{domain}}/$HOSTNAME/" /etc/dovecot/dovecot-sql.conf.ext

postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"

adduser vmail --gecos --system --group --uid 2000 --disabled-login --no-create-home

mkdir -p /var/vmail/
chown -R vmail:vmail /var/vmail/ 


touch $LEMP_FLAG_DIR/POSTFIX_ADMIN_INSTALLED