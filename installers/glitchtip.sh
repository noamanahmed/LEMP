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


# Docker version is deprecated now
# mkdir -p /opt/glitchtip
# cp $template_path/glitchtip/docker-composer.yml /opt/glitchtip/
# cp $template_path/glitchtip/glitchtip.service /etc/systemd/systemd/

# nginx_vhost_file="/etc/nginx/sites-available/glitchtip.conf"
# nginx_vhost_enabled="/etc/nginx/sites-enabled/glitchtip.conf"
# cp $template_path/glitchtip/vhost.conf $nginx_vhost_file

# sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

# ln -s $nginx_vhost_file $nginx_vhost_enabled

# systemctl daemon-reload
# systemctl start glitchtip
# systemctl enable glitchtip
# systemctl reload nginx

glitchtip_path=/opt/glitchtip

#Install poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
source $HOME/.poetry/env

#Initiate setup
mkdir -p $glitchtip_path
git clone https://gitlab.com/glitchtip/glitchtip-backend.git $glitchtip_path/backend.
cd $glitchtip_path/backend
poetry install
poetry remove uWSGI
poetry add gunicorn
cd $DIR
#Setup DB Users
adduser glitchtip --disabled-login
sudo -u postgres createuser glitchtip
sudo -u postgres createdb -O glitchtip glitchtip
#Setup backend app itself
mkdir -p $glitchtip_path/runtime
cp $template_path/glitchtip/.env $glitchtip_path/
sed -i "s/{{domain}}/$hostname/" $glitchtip_path/.env
sed -i "s/{{hash}}/$(openssl rand -hex 32)/" $glitchtip_path/.env

chown -R glitchtip:glitchtip $glitchtip_path
sudo -u glitchtip -c "'python $glitchtip_path/manage.py migrate'"

git clone https://gitlab.com/glitchtip/glitchtip-frontend.git $glitchtip_path/frontend
npm install --prefix $glitchtip_path/frontend/
npm install --prefix run build-prod


nginx_vhost_file="/etc/nginx/sites-available/glitchtip.conf"
nginx_vhost_enabled="/etc/nginx/sites-enabled/glitchtip.conf"
cp $template_path/glitchtip/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$hostname/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx
