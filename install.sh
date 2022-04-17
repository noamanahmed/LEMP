#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


while getopts h:d: flag
do
    case "${flag}" in
        h) hostname=${OPTARG};;        
        u) username=${OPTARG};;
    esac
done

if [ -z "$hostname" ]
then
    echo "Please provide a hostname using -h "
    exit
fi

apt-get update -y
apt-get upgrade -y

## Install prereqs
bash prereq.sh

## Install Security related packages
bash fail2ban.sh
bash ufw.sh
## Install LEMP
bash nginx.sh
bash php.sh
bash mysql.sh

## Install Misc
bash proftpd.sh
bash ssl.sh
bash redis.sh
bash nvm.sh
bash redis.sh
bash docker.sh
bash composer.sh
bash docker.sh
bash java.sh
bash meilisearch.sh
bash jenkins.sh

## Install User jail
bash jail.sh

## Install misc scripts
bash scripts.sh

## Setup hostname site for phpmyadmin and other stuff
bash create-site -u noaman -d $hostname -p 8.1

bash phpmyadmin.sh

