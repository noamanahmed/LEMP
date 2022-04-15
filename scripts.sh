#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


cp -rf $template_path/ssh/.profile $HOME/.profile
cp -rf $template_path/ssh/.bashrc $HOME/.bashrc

source $HOME/.profile
source $HOME/.bashrc


# Installing WP CLI

curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/bin/wp
chmod +x /usr/bin/wp


composer global require laravel/installer

