#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cp $template_path/cron/certbot /var/spool/cron/root
crontab -u root /var/spool/cron/certbot/root
rm /var/spool/cron/root

crontab -u root $template_path/cron/certbot
crontab -u root $template_path/cron/mailserver
crontab -u root $template_path/cron/backup-sites

