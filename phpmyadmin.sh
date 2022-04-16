#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip -O /tmp/phpmyadmin.zip
unzip phpMyAdmin-5.1.1-all-languages.zip 
mv phpMyAdmin-5.1.1-all-languages /home/noaman/www/phpmyadmin
cp $template_path/phpmyadmin /home/noaman/www/phpmyadmin
