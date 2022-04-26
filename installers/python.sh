#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt install make build-essential libssl-dev zlib1g-dev 
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm 
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -qqy 

# Install pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# #Install poetry
# curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
# source $HOME/.poetry/env
source $HOME/.profile
source $HOME/.bashrc
exec $SHELL

#Install python version 3.8.5
pyenv install 3.8.5
pyenv global 3.8.5

python3 -m pip install --user pipx
python3 -m pipx ensurepath
exec $SHELL

