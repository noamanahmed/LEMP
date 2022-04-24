#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

