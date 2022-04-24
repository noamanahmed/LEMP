#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


while getopts h: flag
do
    case "${flag}" in        
        h) hostname=${OPTARG};;
    esac
done


if [ -z "$hostname" ]
then
    echo "Please provide a hostname using -h "
    exit
fi



mkdir -p /opt/glitchtip
cp $template_path/glitchtip/docker-composer.yml /opt/glitchtip/
cp $template_path/glitchtip/glitchtip.service /etc/systemd/systemd/

nginx_vhost_file="/etc/nginx/sites-available/glitchtip.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/glitchtip.conf"
cp $template_path/glitchtip/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled

systemctl daemon-reload
systemctl start glitchtip
systemctl enable glitchtip
systemctl reload nginx

