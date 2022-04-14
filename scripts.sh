#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cp -rf $template_path/.profile $HOME/.profile
cp -rf $template_path/.bashrc $HOME/.bashrc
cp -rf $template_path/.zshrc $HOME/.zshrc
source $HOME/.profile
source $HOME/.bashrc