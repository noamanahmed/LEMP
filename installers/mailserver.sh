#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Helper file to setup complete mailserver as this process is a little complicated
# Install.sh would have been alot compliciated
bash postfix.sh
systemctl stop postfix
bash dovecot.sh
systemctl stop dovecot
bash postfixadmin.sh

