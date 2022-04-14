#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install python3
sudo apt install python3 python3-pip -y


# Install Certbot
sudo apt install certbot python3-certbot-nginx -y
