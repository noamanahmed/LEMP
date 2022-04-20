#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Install from PHP 7.0 to 8.1
apt install unixodbc -y
apt install libc-client2007e-dev -y
apt install software-properties-common -y
apt install sendmail -y

the_ppa="ondrej/php"

if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
    add-apt-repository ppa:ondrej/php -y
    apt update -y
fi

apt install --reinstall php8.1 -y
apt install --reinstall php8.1-common php8.1-mcrypt php8.1-tidy php8.1-xmlrpc php8.1-intl php8.1-fpm php8.1-cli php8.1-fileinfo php8.1-mysql php8.1-xml php8.1-curl php8.1-gd php8.1-imagick php8.1-cli php8.1-dev php8.1-imap php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-redis -y

apt install --reinstall php8.0 -y
apt install --reinstall php8.0-common php8.0-mcrypt php8.0-tidy php8.0-xmlrpc php8.0-intl php8.0-fpm php8.0-cli php8.0-fileinfo php8.0-mysql php8.0-xml php8.0-curl php8.0-gd php8.0-imagick php8.0-cli php8.0-dev php8.0-imap php8.0-mbstring php8.0-opcache php8.0-soap php8.0-zip php8.0-redis -y

apt install --reinstall php7.4 -y
apt install --reinstall php7.4-common php7.4-mcrypt php7.4-tidy php7.4-xmlrpc php7.4-intl php7.4-fpm php7.4-cli php7.4-fileinfo php7.4-mysql php7.4-xml php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-redis -y

apt install --reinstall php7.3 -y
apt install --reinstall php7.3-common php7.3-mcrypt php7.3-tidy php7.3-xmlrpc php7.3-intl php7.3-fpm php7.3-cli php7.3-fileinfo php7.3-mysql php7.3-xml php7.3-curl php7.3-gd php7.3-imagick php7.3-cli php7.3-dev php7.3-imap php7.3-mbstring php7.3-opcache php7.3-soap php7.3-zip php7.3-redis -y


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

cp -rf $DIR/templates/php/7.3/* /etc/php/7.3/
cp -rf $DIR/templates/php/7.4/* /etc/php/7.4/
cp -rf $DIR/templates/php/8.0/* /etc/php/8.0/
cp -rf $DIR/templates/php/8.1/* /etc/php/8.1/


ln -s $(which php7.3) /usr/bin/php73
ln -s $(which php7.4) /usr/bin/php74
ln -s $(which php8.0) /usr/bin/php80
ln -s $(which php8.1) /usr/bin/php81