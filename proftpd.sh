#!/bin/bash

if [ "$EUID" -e 0 ]
  then echo "Please don't run this as root"
  exit
fi

# Install OpenSSL
sudo apt-get install openssl -y

# Install Proftpd
sudo apt-get install proftpd -y




sudo systemctl start proftpd
sudo systemctl enable proftpd