#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


python=3.9
username=pgadmin
user_root=/opt/pgadmin

rm -rf /opt/pgadmin
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username
usermod -a -G $username nginx

wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v6.8/source/pgadmin4-6.8.tar.gz -O /tmp/pgadmin.tar.gz
tar xf /tmp/pgadmin.tar.gz -C /tmp/
rm -rf $user_root
mv /tmp/pgadmin4-6.8 $user_root
python3 -m venv /opt/$username/.venv
#virtualenv --python=python$python /opt/$username/.virtualenv
source /opt/$username/.venv/bin/activate
# curl https://bootstrap.pypa.io/get-pip.py --output /tmp/get-pip.py
# python$python /tmp/get-pip.py

wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v6.8/pip/pgadmin4-6.8-py3-none-any.whl -O /tmp/pgadmin4-6.8-py3-none-any.whl
python$python -m pip install -U pip
python$python -m pip install wheel
python$python -m pip install /tmp/pgadmin4-6.8-py3-none-any.whl
python$python -m pip install gunicorn
cp $template_path/pgadmin/config_local.py /opt/$username/.virtualenv/lib/python$python/site-packages/pgadmin4/config_local.py
python$python /opt/$username/.virtualenv/lib/python$python/site-packages/pgadmin4/setup.py
#gunicorn --bind 127.0.0.1:7210 --chdir /opt/$username/.virtualenv/lib/python$python/site-packages/pgadmin4/  wsgi:pgAdmin4.wsgi

chown -R $username:$username /var/lib/pgadmin4
chown -R $username:$username /var/log/pgadmin4

chown -R $username:$username $user_root
cp $template_path/pgadmin/pgadmin.service /etc/systemd/system/
sed -i "s/{{python}}/$python/" /etc/systemd/system/pgadmin.service
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/g"  /etc/systemd/system/pgadmin.service
systemctl daemon-reload
systemctl restart pgadmin
systemctl enable pgadmin

nginx_vhost_file="/etc/nginx/apps-available/pgadmin.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/pgadmin.conf"
cp $template_path/pgadmin/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file
sed -i "s/{{user_root}}/$(echo $user_root | sed 's/\//\\\//g')/"  $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx

