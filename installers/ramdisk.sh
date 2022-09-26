#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


sudo mkdir -p /var/cache/nginx/ramcache
sudo mount -t tmpfs -o size=1G tmpfs /var/cache/nginx/ramcache


touch $LEMP_FLAG_DIR/RAMDISK_INSTALLED
