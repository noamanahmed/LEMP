#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


echo 'deb http://www.rabbitmq.com/debian/ testing main' | sudo tee /etc/apt/sources.list.d/rabbitmq.list
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -

apt update

apt install rabbitmq-server -y

systemctl start rabbitmq-server
systemctl enable rabbitmq-server

rabbitmq_password="$(openssl rand -hex 12)"
rabbitmqctl add_user admin $rabbitmq_password
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
rabbitmq-plugins enable rabbitmq_management


nginx_vhost_file="/etc/nginx/sites-available/rabbitmq.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/rabbitmq.conf"
cp $template_path/rabbitmq/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx


