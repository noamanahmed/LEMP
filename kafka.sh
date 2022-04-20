#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

adduser --gecos "" --disabled-password kafka


mkdir -p /opt/kafka
curl "https://downloads.apache.org/kafka/3.1.0/kafka_2.12-3.1.0.tgz" -o /opt/kafka/kafka.tgz
tar -xvzf /opt/kafka/kafka.tgz -C /opt/kafka/
mv /opt/kafka/kafka_2.12-3.1.0/* /opt/kafka/
mkdir -p /opt/kafka/logs/
cp $template_path/kafka/kafka.service /etc/systemd/system/
cp $template_path/kafka/zookeeper.service /etc/systemd/system/
chown -R kafka:kafka  /opt/kafka/
systemctl daemon-reload
systemctl start kafka
systemctl enable zookeeper
systemctl enable kafka


