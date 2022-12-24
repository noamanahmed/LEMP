#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



#Installing Docker

apt install apt-transport-https ca-certificates curl software-properties-common -qqy
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
apt-cache policy docker-ce
apt install docker-ce -qqy
apt install docker-compose -qqy


# For Permission Issues
# sudo usermod -aG docker ${USER}


touch $LEMP_FLAG_DIR/DOCKER_INSTALLED