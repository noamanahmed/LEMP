#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



#Install Redis

sudo apt install redis-server -y

sed -i "s/supervised no/supervised systemd/" /etc/redis/redis.conf
sudo systemctl restart redis.service
