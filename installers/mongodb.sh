#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common -qqy

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' -y
apt update -qqy


apt install mongodb -qqy
cp $template_path/mongodb/mongodb.conf /etc/mongodb/mongodb.conf
systemctl stop mongodb
systemctl enable --now mongodb