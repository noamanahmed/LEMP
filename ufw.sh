#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
## For SSH
ufw allow ssh
ufw allow 6000/tcp
##For Kibana
ufw allow 6100/tcp 
##For Nginx
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable


