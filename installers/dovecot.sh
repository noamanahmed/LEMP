#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install dovecot-imapd dovecot-pop3d dovecot-mysql -qqy

cp $template_path/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
sed -i "s/{{domain}}/$HOSTNAME/" /etc/dovecot/dovecot.conf
adduser dovecot mail
