#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add
sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

apt install pgadmin4 pgadmin4-web -qqy
apt update

email="noamanahmed99@gmail.com"
password="noaman"

if [[ ! -d "$PGADMIN_SETUP_EMAIL" ]]; then 
    export PGADMIN_SETUP_EMAIL="${email}"
    export PGADMIN_SETUP_PASSWORD="${password}"
    echo 'export PGADMIN_SETUP_EMAIL="${email}"' >> ~/.bashrc
    echo 'export PGADMIN_SETUP_PASSWORD="${password}"' >> ~/.bashrc
fi

. /usr/pgadmin4/bin/setup-web.sh --yes