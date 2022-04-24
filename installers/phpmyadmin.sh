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


wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip -O /tmp/phpmyadmin.zip
unzip -o -d /tmp/ /tmp/phpmyadmin.zip  
rm -rf /home/$username/www/phpmyadmin
mv -f /tmp/phpMyAdmin-5.1.1-all-languages /home/$username/www/phpmyadmin
cp -rf $template_path/phpmyadmin/* /home/$username/www/phpmyadmin/
