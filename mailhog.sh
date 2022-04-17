#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



apt  install golang-go -y
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