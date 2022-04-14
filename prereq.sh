#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



#Install prereq

apt-get install screen htop nload curl wget git -y
