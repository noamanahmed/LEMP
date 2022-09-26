#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

(crontab -u root -l; echo "$(cat $template_path/cron/certbot)" ) | sort -u | crontab -u root -
(crontab -u root -l; echo "$(cat $template_path/cron/backup-sites)" ) | sort -u | crontab -u root -
(crontab -u root -l; echo "$(cat $template_path/cron/mailserver)" ) | sort -u | crontab -u root -



touch $LEMP_FLAG_DIR/CRON_INSTALLED