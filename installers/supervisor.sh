#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh



if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install supervisor
apt-get install supervisor -qqy


touch $LEMP_FLAG_DIR/SUPERVISOR_INSTALLED