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

python_versions_array=( "2.7" "3.1" "3.2" "3.3" "3.4" "3.5" "3.6" "3.7" "3.8" "3.9" "3.10")

for python_version in ${python_versions_array[@]}; do
  apt install python$python_version -qqy
  
  if [ ! -L "/usr/bin/$(echo "python$python_version" | sed 's/\.//')" ] 
  then
    ln -s $(which python$python_version) /usr/bin/$(echo "python$python_version" | sed 's/\.//')
  fi
done


# https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tar.xz
# https://www.python.org/ftp/python/3.9.12/Python-3.9.12.tar.xz
# https://www.python.org/ftp/python/3.10.3/Python-3.10.3.tar.xz

# Depreceated Lets install from the source
# apt install make build-essential libssl-dev zlib1g-dev 
# libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm 
# libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -qqy 

# # Install pyenv
# curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# # #Install poetry
# # curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
# # source $HOME/.poetry/env
# source $HOME/.profile
# source $HOME/.bashrc


# #Install python version 3.8.5
# pyenv install 3.8.5
# pyenv global 3.8.5

# python3 -m pip install --user pipx
# python3 -m pipx ensurepath
# exec $SHELL

