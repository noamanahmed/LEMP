#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



#Install Redis

sudo apt install redis-server -qqy

cp $template_path/redis/redis.conf /etc/redis/redis.conf
#password=$(openssl rand 60 | openssl base64 -A)
password=$(openssl rand -hex 32)
sed -i "s/{{password}}/$password/" /etc/redis/redis.conf
usermod -a -G nginx redis
systemctl restart redis.service
