#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

exists()
{
  command -v "$1" >/dev/null 2>&1
}


if [ $(exists nginx) ]
then
  #Remove apache2
  apt-get remove apache2 -y
  #Install nginx 
  groupadd web
  apt-get install nginx -y
  cp $template_path/nginx/nginx.conf /etc/nginx/nginx.conf
  cp $template_path/nginx/htpasswd /etc/nginx/htpasswd
  cp $template_path/nginx/performance.conf /etc/nginx/performance.conf
  
  useradd -s /bin/false nginx
  systemctl restart nginx
  systemctl enable nginx
else
  echo "Nginx is already installed!"
fi





