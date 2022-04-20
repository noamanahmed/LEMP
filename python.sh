#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install -o=Dpkg::Use-Pty=0 -qqy python3 python3-pip 
apt install -o=Dpkg::Use-Pty=0 -qqy build-essential libssl-dev libffi-dev python3-dev 
apt install -o=Dpkg::Use-Pty=0 -qqy python3-venv

mkdir -p /opt/python3
mkdir -p /opt/python3/environments



