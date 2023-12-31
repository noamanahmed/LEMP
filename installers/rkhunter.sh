#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install rkhunter -qqy
cp -rf $template_path/rkhunter/rkhunter.conf /etc/rkhunter.conf


touch $LEMP_FLAG_DIR/RKHUNTER_INSTALLED
