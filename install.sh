#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt-get update -y
apt-get upgrade -y

bash prereq.sh
bash nginx.sh
bash php.sh
bash mysql.sh
bash ssl.sh
bash redis.sh
bash nvm.sh
bash redis.sh
bash docker.sh
bash composer.sh
bash scripts.sh

