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

cp -rf $template_path/ssh/sshd_config /etc/ssh/sshd_config
mkdir -p /home/$username/.ssh
cp -rf $template_path/ssh/.ssh/* /home/$username/.ssh/
cp -rf $template_path/ssh/.profile /home/$username/.ssh/
cp -rf $template_path/ssh/.bashrc /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh
systemctl restart ssh
systemctl restart sshd