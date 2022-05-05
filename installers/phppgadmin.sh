#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

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
    echo "Please provide a username using -u "
    exit
fi

git clone https://github.com/phppgadmin/phppgadmin /var/www/home/$username/www/phppgadmin
cp /var/www/home/$username/www/phppgadmin/conf/config.inc.php-dist /var/www/home/$username/www/phppgadmin/conf/config.inc.php
fix-permissions -u $username
