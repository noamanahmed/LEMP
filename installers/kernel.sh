#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"

cp $template_path/kernel/sysctl.conf /etc/sysctl.conf
sysctl -p /etc/sysctl.conf