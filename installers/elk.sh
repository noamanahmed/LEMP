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



## Install elasticseaerch

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
rm -rf /etc/apt/sources.list.d/elastic-7.x.list
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt update
apt install elasticsearch -y
cp $template_path/elasticsearch/elasticsearch.yml /etc/elasticsearch/
systemctl stop elasticsearch

## Install Kibana

apt install kibana -y
systemctl stop kibana
cp $template_path/kibana/kibana.yml /etc/kibana/

nginx_vhost_file="/etc/nginx/apps-available/kibana.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/kibana.conf"
cp $template_path/kibana/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled

systemctl reload nginx

## Install LogStash
apt install logstash -y
systemctl stop logstash
cp -rf $template_path/logstash/* /etc/logstash/


## Install filebeat
apt install filebeat -ym
cp $template_path/filebeat/filebeat.yml /etc/filebeat/


#Lets start all the services
systemctl start elasticsearch
systemctl enable elasticsearch

systemctl start kibana
systemctl enable kibana
systemctl start logstash
systemctl enable logstash
systemctl start filebeat
systemctl enable filebeat


#Final Filebeat configuration (requires elastic search)
filebeat modules enable system
filebeat setup --pipelines --modules system
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'
filebeat setup -E output.logstash.enabled=false -E output.elasticsearch.hosts=['localhost:9200'] -E setup.kibana.host=localhost:5601
