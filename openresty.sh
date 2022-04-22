#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -

echo "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
    | sudo tee /etc/apt/sources.list.d/openresty.list

apt update -qqy
apt install openresty -qqy