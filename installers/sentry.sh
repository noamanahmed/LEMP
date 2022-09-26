#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi





nginx_vhost_file="/etc/nginx/apps-available/sentry.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/sentry.conf"
cp $template_path/sentry/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx


touch $LEMP_FLAG_DIR/SENTRY_INSTALLED
