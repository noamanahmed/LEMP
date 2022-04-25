#!/bin/bash

if [ "$EUID" -e 0 ]
  then echo "Please run this as root"
  exit
fi

# Remove already exisitng versions
rm -rf $(which node)
rm -rf $(which npm)

# Install NVM -- Node Version Manager
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node
nvm use stable
