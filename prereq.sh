#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

exists()
{
  command -v "$1" >/dev/null 2>&1
}


#Install prereq
echo ""
echo ""
echo "_________________________"
echo ""
echo "Installing Pre Req Binaries"
echo ""
binaries_array=("screen" "htop"  "nload" "curl" "wget" "git" "unrar" "unzip" "zip" "speedtest-cli" )

for binary in ${binaries_array[@]}; do      
  if ! command -v $binary &> /dev/null
  then    
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
