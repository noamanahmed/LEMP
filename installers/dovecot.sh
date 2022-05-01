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
systemctl stop dovecot
cp $template_path/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
cp $template_path/dovecot/conf.d/* /etc/dovecot/conf.d/
sed -i "s/{{domain}}/$HOSTNAME/" /etc/dovecot/dovecot.conf
adduser dovecot mail


dovecot_files_array=(  "10-auth.conf" "10-mail.conf" "10-master.conf" "10-ssl.conf" "15-mailboxes.conf" )


for dovecot_file in ${dovecot_files_array[@]}; do
    sed -i "s/{{db_name}}/$database_name/" /etc/dovecot/conf.d/$dovecot_file
    sed -i "s/{{db_username}}/$database_user/" /etc/dovecot/conf.d/$dovecot_file
    sed -i "s/{{db_password}}/$database_password/" /etc/dovecot/conf.d/$dovecot_file
    sed -i "s/{{domain}}/$HOSTNAME/" /etc/dovecot/conf.d/$dovecot_file
done
 