#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Install nginx 

apt-get install nginx -y
systemctl start nginx
systemctl enable nginx