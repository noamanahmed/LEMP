#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install python3 python3-pip -qqy
apt install build-essential libssl-dev libffi-dev python3-dev -qqy
apt install -qqy python3-venv

mkdir -p /opt/python3
mkdir -p /opt/python3/environments



