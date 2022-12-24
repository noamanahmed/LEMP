#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install fail2ban -qqy
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local


touch $LEMP_FLAG_DIR/FAIL2BAN_INSTALLED
