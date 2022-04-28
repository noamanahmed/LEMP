#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install ufw -y
#Basic security
ufw default deny incoming
ufw default allow outgoing
## For SSH
ufw allow ssh
ufw allow 6000/tcp
##For Kibana
ufw allow 6100/tcp
##For RabbitMQ
ufw allow 6110/tcp
##For MailHog
ufw allow 6120/tcp
##For Netdata
ufw allow 6130/tcp
##For GlitchTip
ufw allow 6140/tcp 
##For Jenkins
ufw allow 6150/tcp
##For Sentry
ufw allow 6160/tcp 
##For Monit
ufw allow 6170/tcp 
##For Nginx
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable


