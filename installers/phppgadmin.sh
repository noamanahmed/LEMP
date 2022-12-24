#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u: flag
do
    case "${flag}" in
        u) username=${OPTARG};; 
    esac
done



if [ -z "$username" ]
then
    username=$LEMP_HOSTNAME_USERNAME
fi

if ! id "$username" &>/dev/null
then
    echo "The $username doesn't exist!"
    exit
fi

git clone https://github.com/phppgadmin/phppgadmin /var/www/home/$username/www/public/phppgadmin
cp /var/www/home/$username/www/public/phppgadmin/conf/config.inc.php-dist /var/www/home/$username/www/public/phppgadmin/conf/config.inc.php
fix-permissions -u $username


touch $LEMP_FLAG_DIR/PHPPGADMIN_INSTALLED