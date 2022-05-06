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
email=admin@$HOSTNAME
password=pgadmin
user_root=/opt/pgadmin

# Debuggin
rm -rf /opt/pgadmin
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username
usermod -a -G $username nginx

wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v6.8/source/pgadmin4-6.8.tar.gz -O /tmp/pgadmin.tar.gz
tar xf /tmp/pgadmin.tar.gz -C /tmp/
rm -rf $user_root
mv /tmp/pgadmin4-6.8 $user_root 
virtualenv --python=python$python /opt/$username/.virtualenv
source /opt/$username/.virtualenv/bin/activate
curl https://bootstrap.pypa.io/get-pip.py --output /tmp/get-pip.py
python$python /tmp/get-pip.py

wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v6.8/pip/pgadmin4-6.8-py3-none-any.whl -O /tmp/pgadmin4-6.8-py3-none-any.whl
python$python -m pip --no-cache-dir install -U pip
python$python -m pip --no-cache-dir install wheel
python$python -m pip --no-cache-dir install /tmp/pgadmin4-6.8-py3-none-any.whl
python$python -m pip --no-cache-dir install gunicorn
cp $template_path/pgadmin/config_local.py /opt/$username/.virtualenv/lib/python$python/site-packages/pgadmin4/config_local.py

if [[ ! -d "$PGADMIN_SETUP_EMAIL" ]]; then 
    export PGADMIN_SETUP_EMAIL="${email}"
    export PGADMIN_SETUP_PASSWORD="${password}"
    echo 'export PGADMIN_SETUP_EMAIL="${email}"' >> ~/.bashrc
    echo 'export PGADMIN_SETUP_PASSWORD="${password}"' >> ~/.bashrc
fi

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

#Salt select value from keys where name = 'SECURITY_PASSWORD_SALT';
#Insert into user (username,email,password,active,fs_uniquifier) values ('test','test@gmail.com','password',1,123);