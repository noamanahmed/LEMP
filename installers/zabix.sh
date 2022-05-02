#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-1+ubuntu20.04_all.deb -O /tmp/zabbix.deb
dpkg -i /tmp/zabbix.deb
apt update
apt install zabbix-agent -qqy

cp $template_path/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
server_ip=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
sed -i "s/{{server_ip}}/$server_ip/" $nginx_vhost_file
systemctl restart zabbix-agent