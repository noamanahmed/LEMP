#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cp -rf $template_path/ssh/sshd_config /etc/ssh/sshd_config
mkdir -p /root/.ssh
cp -rf $template_path/ssh/.ssh/* /root/.ssh/
cp -rf $template_path/ssh/.profile /root/.ssh/
cp -rf $template_path/ssh/.bashrc /root/.ssh/
systemctl restart ssh
systemctl restart sshd