#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

sudo apt-get install openssl shellinabox -qqy
cp $template_path/shellinabox/shellinabox /etc/default/shellinabox
cp $template_path/shellinabox/shellinabox.service /etc/systemd/system/shellinabox.service
systemctl daemon-reload
systemctl restart shellinabox



nginx_vhost_file="/etc/nginx/apps-available/shellinabox.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/shellinabox.conf"
cp $template_path/shellinabox/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx


touch $LEMP_FLAG_DIR/SHELLINABOX_INSTALLED
