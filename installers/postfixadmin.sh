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
user_root=/opt/postfixadmin
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username

# Get Source Code
wget https://github.com/postfixadmin/postfixadmin/archive/postfixadmin-3.3.11.tar.gz
tar xvf postfixadmin-3.3.11.tar.gz -C /tmp/
rm -rf $user_root
mv /var/www/postfixadmin-postfixadmin-3.3.11 $user_root
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

## Setting up postfix admin
nginx_vhost_file="/etc/nginx/app-available/postfixadmin.conf"
nginx_vhost_enabled="/etc/nginx/app-enabled/postfixadmin.conf"
cp $template_path/postfixadmin/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

## We need to setup SQL for postfix


cp $template_path/postfix/main.cf /etc/postfix/main.cf
sed -i "s/{{domain}}/$HOSTNAME/" /etc/postfix/main.cf

mkdir -p /etc/postfix/sql/
cp -rf $template_path/postfix/sql/* /etc/postfix/sql/
chmod -R 0640 /etc/postfix/sql/*


sql_files_array=( "mysql_virtual_alias_domain_catchall_maps.cf" "mysql_virtual_alias_domain_mailbox_maps.cf" "mysql_virtual_alias_domain_maps.cf" "mysql_virtual_alias_maps.cf" "mysql_virtual_domains_maps.cf" "mysql_virtual_mailbox_maps.cf" )

for sql_file in ${sql_files_array[@]}; do
    sed -i "s/{{db_name}}/$database_name/" /etc/postfix/sql/$sql_file
    sed -i "s/{{db_username}}/$database_user/" /etc/postfix/sql/$sql_file
    sed -i "s/{{db_password}}/$database_password/" /etc/postfix/sql/$sql_file
done

sed -i "s/{{db_name}}/$database_name/" /etc/postfix/main.cf
sed -i "s/{{db_username}}/$database_user/" /etc/postfix/main.cf
sed -i "s/{{db_password}}/$database_password/" /etc/postfix/main.cf

postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"

adduser vmail --system --group --uid 2000 --disabled-login --no-create-home
mkdir /var/vmail/
chown -R vmail:vmail /var/vmail/ 
