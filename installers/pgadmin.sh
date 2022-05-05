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
# Create User
adduser --gecos "" --disabled-password  --home $user_root  $username
usermod -a -G $username nginx

wget https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v6.8/source/pgadmin4-6.8.tar.gz -O /tmp/pgadmin.tar.gz
tar xf /tmp/pgadmin.tar.gz -C /tmp/
rm -rf $user_root
mv /tmp/pgadmin4-6.8 $user_root 
# curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
# sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# apt install pgadmin4 pgadmin4-web -qqy
# apt update

# email="noamanahmed99@gmail.com"
# password="noaman"

# if [[ ! -d "$PGADMIN_SETUP_EMAIL" ]]; then 
#     export PGADMIN_SETUP_EMAIL="${email}"
#     export PGADMIN_SETUP_PASSWORD="${password}"
#     echo 'export PGADMIN_SETUP_EMAIL="${email}"' >> ~/.bashrc
#     echo 'export PGADMIN_SETUP_PASSWORD="${password}"' >> ~/.bashrc
# fi

# . /usr/pgadmin4/bin/setup-web.sh --yes