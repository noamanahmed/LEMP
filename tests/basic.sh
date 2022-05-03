#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

### This is a basic site test to create different kinds of sites rapidly
### This tests assumes that a wildcard DNS entry has been setup for *.HOSTNAME
### Otherswise there would be no site created

## Lets clean up previous attempt if there was any
delete-site -u php1 -y
delete-site -u php2 -y
delete-site -u wordpress -y
delete-site -u laravel -y
delete-site -u node1 -y
delete-site -u python1 -y
delete-site -u angular1 -y
delete-site -u react1 -y
delete-site -u vue1 -y
delete-site -u svelte1 -y

## Lets begin with PHP

create-site-php -u php1 -d php1.$HOSTNAME 
create-site-php -u php2 -d php2.$HOSTNAME --php 8.1 

create-site-php -u wordpress -d wordpress.$HOSTNAME --wordpress
## By defauly laravel site should give a 404 nginx error as nginx is looking
## for a public dir in $CHROOT_DIR/home/$username/www
## We wiil further update this script in future to auto git clone to setup
## laravel project, composer install, php artisan key:generate , php artisan migrate fresh
## , npm install, npm run build
## But for now lets keep it plain and simple!
create-site-php -u laravel -d laravel.$HOSTNAME --laravel


## Let switch gears to Node
create-site-node -u node1 -d node1.$HOSTNAME --port 11000


## Let switch gears to Python
create-site-python -u python1 -d python1.$HOSTNAME --port  11010


## Lets setup a pure frontend app built on frameworks and libraires
## These app require configuration to be done by the developer to setup
## API URL for connecting with the backend. This part is out of scope
## We will only generate boiler plate react apps with dist,public folders
## removed in .gitignore to avoid time in building prod builds using npm run build
## NPM and Node will come pre installed in these sites  
## Enough talks! Lets deploy!
create-site-angular -u angular1 -d angular1.$HOSTNAME 
create-site-react -u react1 -d react1.$HOSTNAME 
create-site-vue -u vue1 -d vue1.$HOSTNAME 
create-site-svelte -u svelte1 -d svelte1.$HOSTNAME 

