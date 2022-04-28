#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u:p: flag
do
    case "${flag}" in
        u) username=${OPTARG};;        
        p) password=${OPTARG};;        
    esac
done

if [ -z "$username" ]
then
    echo "Please provide a username using -u "
    exit
fi

 
if [ -z "$password" ]
then
    echo "Please provide a password using -p "
    exit
fi

apt install monit -qqy
cp $template_path/monit/monitrc /etc/monit/monitrc
sed -i "s/{{username}}/$username/" /etc/monit/monitrc
sed -i "s/{{password}}/$password/" /etc/monit/monitrc
ln -s /etc/monit/conf-available/nginx /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/mysql /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/openssh-server /etc/monit/conf-enabled/
ln -s /etc/monit/conf-available/cron /etc/monit/conf-enabled/
php_versions_array=("8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )

for php_version in ${php_versions_array[@]}; do
    if [ -L "/etc/monit/conf-enabled/php-$php_version" ] 
    then
        rm -rf /etc/monit/conf-enabled/php-$php_version
    fi
    cp $template_path/monit/php-fpm/$php_version.conf /etc/monit/conf-available/php-$php_version
    ln -s /etc/monit/conf-available/php-$php_version /etc/monit/conf-enabled/    
done

cp $template_path/monit/slack-url /etc/monit/slack-url
cp $template_path/monit/slack.sh /usr/local/bin/slack.sh
chmod +x /usr/local/bin/slack.sh
cp $template_path/monit/diskspace.conf /etc/monit/conf-available/
cp $template_path/monit/system.conf /etc/monit/conf-available/
ln -s /etc/monit/conf-available/diskspace.conf /etc/monit/conf-enabled/  
ln -s /etc/monit/conf-available/system.conf /etc/monit/conf-enabled/  

systemctl restart monit


nginx_vhost_file="/etc/nginx/sites-available/monit.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/monit.conf"
cp $template_path/monit/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx