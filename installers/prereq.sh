#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Install prereq
echo ""
echo ""
echo "_________________________"
echo ""
echo "Installing Pre Req Binaries"
echo ""


binaries_array=("software-properties-common" "screen" "htop"  "nload" "curl" "wget" "git" "unrar" "unzip" "zip" "speedtest-cli gzip" "pv" "logrotate" "rig" "runuser" "gnupg" "ca-certificates" "gnupg2" "sqlite3" "jq" "bc" "xclip" "tree")

for binary in ${binaries_array[@]}; do      
  if ! command -v $binary &> /dev/null
  then
    echo "Installing $binary"  
    apt-get install $binary -qqy
  fi
done

if ! command -v ifconfig &> /dev/null
then
  apt-get install net-tools -qqy
fi


if ! command -v iotop &> /dev/null
then
  apt-get install sysstat -qqy
fi

echo ""
echo "All Binaries have been installed"
echo ""
echo "_________________________"
