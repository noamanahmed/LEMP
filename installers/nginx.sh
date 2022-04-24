#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


if command -v apache2 &> /dev/null
then
  #Remove apache2 and its HTML directories
  apt-get remove --purge apache2 -qqy
  rm -rf /var/www/html/  
fi

if ! command -v nginx &> /dev/null
then
  #Remove apache2
  apt-get remove --purge apache2 -qqy
  rm -rf /var/www/html/
  #Install nginx
  adduser --gecos "" --disabled-password --no-create-home  nginx 
  groupadd web
  apt install nginx -y
  
else
  echo "Nginx is already installed!"
fi

systemctl stop nginx
wget -O /etc/nginx/conf.d/blacklist.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blacklist.conf
wget -O /etc/nginx/conf.d/blockips.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blockips.conf
cp $template_path/nginx/nginx.conf /etc/nginx/nginx.conf
sed -i "s/{{cpu_cores}}/$(grep -c ^processor /proc/cpuinfo)/" /etc/nginx/nginx.conf
cp $template_path/nginx/htpasswd.users /etc/nginx/htpasswd.users
cp $template_path/nginx/htpasswd /etc/nginx/htpasswd
cp $template_path/nginx/performance.conf /etc/nginx/performance.conf

# mkdir -p /var/cache/nginx
# chown -R nginx:nginx /etc/nginx/*
# chown -R nginx:nginx /var/cache/nginx*

systemctl restart nginx
systemctl enable nginx





