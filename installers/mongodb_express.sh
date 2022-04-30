#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


adduser --gecos "" --disabled-password --no-create-home mongodb_express

#Get source code
mkdir -p /opt/mongodb_express
git clone https://github.com/mongo-express/mongo-express /opt/mongodb_express
cd /opt/mongodb_express
npm install
cp $template_path/mongodb_express/config.js /opt/mongodb_express/node_modules/mongo-express/
chown -R mongodb_express:mongodb_express /opt/mongodb_express

# Systemd setup
cp $template_path/mongodb_express/mongodb_express.service /etc/systemd/system/mongodb_express.service
systemctl daemon-reload
systemctl start mongodb_express


# Nginx Vhost configuration for reverse proxy with SSL
nginx_vhost_file="/etc/nginx/apps-available/mongodb_express.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/mongodb_express.conf"
cp $template_path/mongodb_express/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx
