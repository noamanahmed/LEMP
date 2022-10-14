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
chmod 600 /etc/monit/monitrc
ln -s $template_path/monit/nginx.conf /etc/monit/conf-enabled/nginx
ln -s $template_path/monit/mysql.conf /etc/monit/conf-enabled/mysql
ln -s $template_path/monit/ssh.conf /etc/monit/conf-enabled/ssh
ln -s $template_path/monit/cron.conf /etc/monit/conf-enabled/cron

php_versions_array=("8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )

for php_version in ${php_versions_array[@]}; do
    if [ -L "/etc/monit/conf-enabled/php-$php_version" ] 
    then
        rm -rf /etc/monit/conf-enabled/php-$php_version
    fi
    cp $template_path/monit/php-fpm/$php_version.conf /etc/monit/conf-available/php-$php_version
    ln -s /etc/monit/conf-available/php-$php_version /etc/monit/conf-enabled/    
    monit monitor php$php_version-fpm
done


cp $template_path/monit/slack.sh /usr/local/bin/slack.sh
chmod +x /usr/local/bin/slack.sh
cp $template_path/monit/diskspace.conf /etc/monit/conf-available/
cp $template_path/monit/system.conf /etc/monit/conf-available/
ln -s /etc/monit/conf-available/diskspace.conf /etc/monit/conf-enabled/  
ln -s /etc/monit/conf-available/system.conf /etc/monit/conf-enabled/  

monit monitor mysqld
monit monitor nginx
monit monitor crond
monit monitor sshd

systemctl restart monit
systemctl enable monit

nginx_vhost_file="/etc/nginx/apps-available/monit.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/monit.conf"
cp $template_path/monit/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

touch $LEMP_FLAG_DIR/MONIT_INSTALLED
