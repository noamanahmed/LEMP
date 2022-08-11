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
## For mail
ufw allow out 25
ufw allow 25/tcp
ufw allow 443/tcp
ufw allow 587/tcp
ufw allow 465/tcp
ufw allow 143/tcp
ufw allow 993/tcp
ufw allow 110/tcp
ufw allow 995/tcp
# For Zabbix Agent
ufw allow 10050/tcp
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
##For MongoDB Express
ufw allow 6180/tcp
##For Postfixadmin
ufw allow 6190/tcp 
##For Roundcube
ufw allow 6200/tcp 
##For PgAdmin
ufw allow 6210/tcp 
##For Shellinabox
ufw allow 6220/tcp 
##For PhpMyAdmin
ufw allow 6230/tcp 
##For Nginx
ufw allow 80/tcp
ufw allow 443/tcp
## For General usage
ufw allow 20000:21000/tcp
ufw --force enable


