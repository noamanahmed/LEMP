#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


if ! command -v nginx &> /dev/null
then
  #Remove apache2
  apt-get remove --purge apache2 -y
  #Install nginx
  adduser --gecos "" --disabled-password --no-create-home  nginx 
  groupadd web
  apt install nginx -y
  systemctl stop nginx
  cp $template_path/nginx/nginx.conf /etc/nginx/nginx.conf
  sed -i "s/{{cpu_cores}}/$(grep -c ^processor /proc/cpuinfo)/" /etc/nginx/nginx.conf
  cp $template_path/nginx/htpasswd.users /etc/nginx/htpasswd.users
  cp $template_path/nginx/htpasswd /etc/nginx/htpasswd
  cp $template_path/nginx/performance.conf /etc/nginx/performance.conf
  
  mkdir -p /var/cache/nginx

  chown -R nginx:nginx /etc/nginx/*
  chown -R nginx:nginx /var/cache/nginx*

  useradd -s /bin/false nginx
  systemctl restart nginx
  systemctl enable nginx
else
  echo "Nginx is already installed!"
fi





