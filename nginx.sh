#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Remove apache2

apt-get remove apache2 -y

#Install nginx 
groupadd web
apt-get install nginx -y
cp $template_path/nginx/nginx.conf /etc/nginx/nginx.conf
useradd -s /bin/false nginx
systemctl start nginx
systemctl enable nginx


