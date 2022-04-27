#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


the_ppa="deadsnakes/ppa"

if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    add-apt-repository ppa:deadsnakes/ppa -y
    apt update -y
fi

python_versions_array=( "2.7" "3.5" "3.6" "3.7" "3.8" "3.9" "3.10")

for python_version in ${python_versions_array[@]}; do
  apt install python$python_version -qqy
  
  if [ ! -L "/usr/bin/$(echo "python$python_version" | sed 's/\.//')" ] 
  then
    ln -s $(which python$python_version) /usr/bin/$(echo "python$python_version" | sed 's/\.//')
  fi
done
