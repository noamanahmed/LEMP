#!/bin/bash
template_path="$(cd ../ && pwd)/templates"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u:d:f:p flag
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



if id "$username" &>/dev/null
then
    echo "Username $username exists!"      
else
    echo "The $username doesn't exist"    
fi

## Create system user if doesnt't exists

# $system_root="/home/$username";
# mkdir -p $system_root
# mkdir -p "$system_root/php/$php_version"



## Reset PHP FPM Pool
php_versions_array=("7.3" "7.4" "8.0" "8.1")

for php_v in ${php_versions_array[@]}; do    
    rm /etc/php/$php_v/fpm/pool.d/$username.conf
    systemctl restart php$php_v-fpm
done

## Deleting nginx settings
rm "/etc/nginx/sites-available/$username.conf"

userdel -r $username


echo "Username $username deleted successfully!"      


