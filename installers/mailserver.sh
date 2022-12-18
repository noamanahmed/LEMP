#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Helper file to setup complete mailserver as this process is a little complicated
# Install.sh would have been alot compliciated
bash $DIR/postfix.sh
systemctl stop postfix
bash $DIR/dovecot.sh
systemctl stop dovecot
bash $DIR/postfixadmin.sh
bash $DIR/roundcube.sh
bash $DIR/dkim.sh
systemctl start opendkim
systemctl start postfix
systemctl start dovecot
systemctl restart nginx

#TODO
#https://www.linuxbabe.com/mail-server/postfix-amavis-spamassassin-clamav-ubuntu
#https://www.linuxbabe.com/mail-server/block-email-spam-check-header-body-with-postfix-spamassassin



touch $LEMP_FLAG_DIR/MAILSERVER_INSTALLED
