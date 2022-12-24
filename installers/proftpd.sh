#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -e 0 ]
  then echo "Please don't run this as root"
  exit
fi

# Install OpenSSL
sudo apt-get install openssl -qqy

# Install Proftpd
sudo apt-get install proftpd -qqy

useradd -s /bin/false sftp


sudo systemctl start proftpd
sudo systemctl enable proftpd


touch $LEMP_FLAG_DIR/PROFTPD_INSTALLED