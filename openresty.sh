#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -

echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
    | sudo tee /etc/apt/sources.list.d/openresty.list

apt update -qqy
apt install openresty -qqy
systemctl stop nginx
systemctl disable nginx
cp $template_path/openresty/nginx-openresty.service /lib/systemd/system/nginx-openresty.service
cp $template_path/openresty/nginx.conf /usr/local/openresty/nginx/conf/
cp -rf /etc/nginx/snippets /usr/local/openresty/nginx/conf/
sed -i "s/{{cpu_cores}}/$(grep -c ^processor /proc/cpuinfo)/" /usr/local/openresty/nginx/conf/nginx.conf


systemctl daemon-reload
systemctl restart nginx-openresty