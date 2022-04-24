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




apt  install golang-go -qqy
mkdir -p $HOME/gocode
echo "export GOPATH=$HOME/gocode" >> ~/.profile
source ~/.profile

go get github.com/mailhog/MailHog
go get github.com/mailhog/mhsendmail


cp $HOME/gocode/bin/MailHog /usr/local/bin/mailhog
cp $HOME/gocode/bin/mhsendmail /usr/local/bin/mhsendmail


cp $template_path/systemd/mailhog.service /etc/systemd/system/

sed -i "s/{{mail_hog_path}}/$(echo $(which mailhog) | sed 's/\//\\\//g')/" /etc/systemd/system/mailhog.service

systemctl daemon-reload
systemctl restart mailhog
systemctl enable mailhog



nginx_vhost_file="/etc/nginx/sites-available/mailhog.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/mailhog.conf"
cp $template_path/mailhog/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

