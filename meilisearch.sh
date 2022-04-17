#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



apt install curl -y

curl -L https://install.meilisearch.com | sh
mv ./meilisearch /usr/bin/
