#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



apt install curl -qqy

curl -L https://install.meilisearch.com | sh
mv ./meilisearch /usr/bin/

cp $template_path/meilisearch/meilisearch.service /etc/systemd/system/


sed -i "s/{{security_key}}/$(openssl rand -hex 24)/" /etc/systemd/system/meilisearch.service
systemctl daemon-reload
systemctl start meilisearch
systemctl enable meilisearch


touch $LEMP_FLAG_DIR/MEILISEARCH_INSTALLED