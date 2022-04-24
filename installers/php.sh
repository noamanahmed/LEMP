#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Install from PHP 7.0 to 8.1
apt install unixodbc -qqy
apt install libc-client2007e-dev -qqy
apt install software-properties-common -qqy
apt install sendmail -qqy

the_ppa="ondrej/php"

if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    add-apt-repository ppa:ondrej/php -y
    apt update -y
fi

php_versions_array=("8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )

for php_version in ${php_versions_array[@]}; do
  apt install php$php_version -qqy
  apt install php$php_version-common php$php_version-mcrypt php$php_version-mongodb php$php_version-tidy php$php_version-xmlrpc php$php_version-intl php$php_version-fpm php$php_version-cli php$php_version-fileinfo php$php_version-mysql php$php_version-xml php$php_version-curl php$php_version-gd php$php_version-imagick php$php_version-cli php$php_version-dev php$php_version-imap php$php_version-mbstring php$php_version-opcache php$php_version-soap php$php_version-zip php$php_version-redis -qqy
  cp -rf $DIR/templates/php/$php_version/* /etc/php/$php_version/

  if [ ! -L "/usr/bin/$(echo "php$php_version" | sed 's/\.//')" ] 
  then
    ln -s $(which php$php_version) /usr/bin/$(echo "php$php_version" | sed 's/\.//')
  fi
done

mkdir -p /opt/php-fpm