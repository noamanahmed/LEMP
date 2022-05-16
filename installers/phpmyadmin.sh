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


wget https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip -O /tmp/phpmyadmin.zip
unzip -o -d /tmp/ /tmp/phpmyadmin.zip  
rm -rf /var/www/home/$username/www/phpmyadmin
mv -f /tmp/phpMyAdmin-5.2.0-all-languages /var/www/home/$username/www/phpmyadmin
cp -rf $template_path/phpmyadmin/* /var/www/home/$username/www/phpmyadmin/
