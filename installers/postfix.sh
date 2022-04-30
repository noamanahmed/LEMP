#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

debconf-set-selections <<< "postfix postfix/mailname string ${HOSTNAME}"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt-get install --assume-yes postfix postfix-mysql
systemctl stop postfix

cp $template_path/postfix/main.cf /etc/postfix/main.cf
sed -i "s/{{domain}}/$HOSTNAME/" /etc/postfix/main.cf

mkdir -p /etc/postfix/sql/
cp -rf $template_path/postfix/sql/* /etc/postfix/sql/
chmod -R 0640 /etc/postfix/sql/*
postconf -e "mydestination = \$myhostname, localhost.\$mydomain, localhost"

adduser vmail --system --group --uid 2000 --disabled-login --no-create-home
mkdir /var/vmail/
chown -R vmail:vmail /var/vmail/ 

