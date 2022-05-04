#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



#Installing Docker

apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
apt-cache policy docker-ce
apt install docker-ce -y
apt install docker-compose -y


# For Permission Issues
# sudo usermod -aG docker ${USER}
