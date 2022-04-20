#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


while getopts h: flag
do
    case "${flag}" in        
        h) hostname=${OPTARG};;
    esac
done



if [ -z "$hostname" ]
then
    echo "Please provide a hostname using -h "
    exit
fi


sed -i "s/$HOSTNAME/$hostname/" /etc/hostname
sed -i "s/$HOSTNAME/$hostname/" /etc/hosts
hostnamectl