#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install opendkim opendkim-tools -qqy
systemctl stop opendkim
gpasswd -a postfix opendkim
mkdir /etc/opendkim
mkdir /etc/opendkim/keys
chown -R opendkim:opendkim /etc/opendkim
chmod go-rw /etc/opendkim/keys
touch /etc/opendkim/signing.table
echo "*@$HOSTNAME    default._domainkey.$HOSTNAME" >> /etc/opendkim/signing.table
echo "*@*.$HOSTNAME    default._domainkey.$HOSTNAME" >> /etc/opendkim/signing.table
touch /etc/opendkim/key.table
echo "default._domainkey.$HOSTNAME     $HOSTNAME:default:/etc/opendkim/keys/$HOSTNAME/default.private" >> /etc/opendkim/key.table
touch /etc/opendkim/trusted.hosts

echo "127.0.0.1" >> /etc/opendkim/trusted.hosts 
echo "localhost" >> /etc/opendkim/trusted.hosts 
echo ".$HOSTNAME" >> /etc/opendkim/trusted.hosts 

mkdir -p /etc/opendkim/keys/$HOSTNAME
opendkim-genkey -b 2048 -d $HOSTNAME -D /etc/opendkim/keys/$HOSTNAME -s default -v
chown opendkim:opendkim /etc/opendkim/keys/$HOSTNAME/default.private
chmod 600 /etc/opendkim/keys/$HOSTNAME/default.private


mkdir -p /var/spool/postfix/opendkim
chown opendkim:postfix /var/spool/postfix/opendkim

cp $template_path/dkim/opendkim.conf /etc/opendkim.conf
cp $template_path/dkim/opendkim /etc/default/opendkim.conf

cat /etc/opendkim/keys/$HOSTNAME/default.txt


touch $LEMP_FLAG_DIR/DKIM_INSTALLED
