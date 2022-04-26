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

## W.I.P
##https://guides.lw1.at/how-to-install-glitchtip-without-docker/#set-up-gunicorn
# glitchtip_path=/opt/glitchtip

# #Install poetry
# curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
# source $HOME/.poetry/env

# #Initiate setup
# mkdir -p $glitchtip_path
# git clone https://gitlab.com/glitchtip/glitchtip-backend.git $glitchtip_path/backend
# cd $glitchtip_path/backend
# sed -i "/uWSGI/d" pyproject.toml      
# poetry install
# poetry add gunicorn
# cd $DIR
# #Setup DB Users
# adduser glitchtip --disabled-login
# su postgres -c 'createuser glitchtip'
# su postgres -c 'createdb -O glitchtip glitchtip'
# #Setup backend app itself
# mkdir -p $glitchtip_path/runtime
# cp $template_path/glitchtip/.env $glitchtip_path/
# sed -i "s/{{domain}}/$hostname/" $glitchtip_path/.env
# sed -i "s/{{hash}}/$(openssl rand -hex 32)/" $glitchtip_path/.env

# chown -R glitchtip:glitchtip $glitchtip_path
# su glitchtip -c "'python $glitchtip_path/backend/manage.py migrate'"

# ##Setting up frontend
# git clone https://gitlab.com/glitchtip/glitchtip-frontend.git $glitchtip_path/frontend
# chown -R glitchtip:glitchtip $glitchtip_path
# username=glitchtip
# curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh -o /home/$username/install.sh
# mkdir /home/$username/.nvm
# chmod +x /home/$username/install.sh
# chown $username:$username  /home/$username/install.sh
# chown $username:$username  /home/$username/.nvm
# cd /home/$username/ 
# su $username -c "NVM_DIR=.nvm /home/$username/install.sh"
# su $username -c "NVM_DIR=/home/$username/.nvm && . /home/$username/.nvm/nvm.sh && . /home/$username/.nvm/bash_completion && nvm install node"
# rm -rf /home/$username/install.sh

# su $username -c "HOME=/home/$username NVM_DIR=/home/$username/.nvm && . /home/$username/.nvm/nvm.sh && . /home/$username/.nvm/bash_completion && cd $glitchtip_path/frontend && npm -f install && npm run build-prod"


# nginx_vhost_file="/etc/nginx/sites-available/glitchtip.conf"
# nginx_vhost_enabled="/etc/nginx/sites-enabled/glitchtip.conf"
# cp $template_path/glitchtip/vhost.conf $nginx_vhost_file

# sed -i "s/{{domain}}/$hostname/" $nginx_vhost_file

# ln -s $nginx_vhost_file $nginx_vhost_enabled
# systemctl reload nginx
