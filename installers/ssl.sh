#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# # Install python3
# sudo apt install python3 python3-pip -y


# Install Certbot
#sudo apt install certbot python3-certbot-nginx -y
mkdir -p /opt/certbot
virtualenv /opt/certbot
/opt/certbot/bin/pip install --upgrade pip
/opt/certbot/bin/pip install certbot
ln -s /opt/certbot/bin/certbot /usr/bin/certbot
mkdir -p /etc/letsencrypt/
cp -rf $template_path/letsencrypt/* /etc/letsencrypt/
