#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


adduser --gecos "" --disabled-password --no-create-home mongodb_express
mkdir -p /opt/mongodb_express

## Install node for this specfic user
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh -o /opt/mongodb_express/install.sh
mkdir /opt/mongodb_express/.nvm
chmod +x /opt/mongodb_express/install.sh
chown $username:$username  /opt/mongodb_express/install.sh
chown $username:$username  /opt/mongodb_express/.nvm
cd /opt/mongodb_express/ 
su $username -c "NVM_DIR=.nvm /opt/mongodb_express/install.sh"
su $username -c "NVM_DIR=/opt/mongodb_express/.nvm && . /opt/mongodb_express/.nvm/nvm.sh && . /opt/mongodb_express/.nvm/bash_completion && nvm install node && npm install mongo-express"

cp $template_path/mongodb_express/config.js /opt/mongodb_express/node_modules/mongo-express/config.js
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
