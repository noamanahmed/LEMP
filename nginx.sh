#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Remove apache2

apt-get remove apache2

#Install nginx 

apt-get install nginx -y
systemctl start nginx
systemctl enable nginx