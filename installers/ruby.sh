#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io -o /tmp/rvm.sh
cat /tmp/rvm.sh | bash -s stable
source ~/.rvm/scripts/rvm
rvm install ruby

# apt install libsqlite3-dev -qqy
# apt install -qqy git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev
# curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
# cd /opt
# git clone https://github.com/rbenv/ruby-build.git
# PREFIX=/usr/local sudo ./ruby-build/install.sh
# source ~/.profile
# rbenv install 3.1.2
# rbenv global 3.1.2
# echo "gem: --no-document" > ~/.gemrc
# gem install rails -v 6.1.4.1
# gem install sqlite3
# rbenv rehash