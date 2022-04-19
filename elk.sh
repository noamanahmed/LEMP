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
        u) username=${OPTARG};;
    esac
done



if [ -z "$hostname" ]
then
    echo "Please provide a hostname using -h "
    exit
fi



## Install elasticseaerch

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
rm -rf /etc/apt/sources.list.d/elastic-7.x.list
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt update
apt install elasticsearch -y
cp $template_path/elasticsearch/elasticsearch.yml /etc/elasticsearch/
systemctl start elasticsearch
systemctl enable elasticsearch

## Install Kibana

apt install kibana -y
systemctl enable kibana
systemctl start kibana

nginx_vhost_file="/etc/nginx/sites-available/kibana.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/kibana.conf"
cp $template_path/kibana/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled

systemctl reload nginx

## Install LogStash
apt install logstash -y
cp -rf $template_path/logstash/* /etc/logstash/
systemctl start logstash
systemctl enable logstash


## Install filebeat
apt install filebeat -yml
cp $template_path/filebeat/filebeat.yml /etc/filebeat/

filebeat modules enable system
filebeat setup --pipelines --modules system
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'
filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601
systemctl start filebeat
systemctl enable filebeat