#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


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


apt install netdata -y

systemctl stop netdata
cp $template_path/netdata/netdata.conf /etc/netdata/

systemctl start netdata
systemctl enable netdata



nginx_vhost_file="/etc/nginx/app-available/netdata.conf"
nginx_vhost_enabled="/etc/nginx/app-enabled/netdata.conf"
cp $template_path/netdata/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

