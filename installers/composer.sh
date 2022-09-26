#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh



if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Installing Composer

php -r "copy('https://getcomposer.org/download/2.3.5/composer.phar', 'composer-setup.php');"
php -r "if (hash_file('sha256', 'composer-setup.php') === '3b3b5a899c06a46aec280727bdf50aad14334f6bc40436ea76b07b650870d8f4') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
cp composer-setup.php /usr/local/bin/composer
cp composer-setup.php /usr/local/bin/composer2



php -r "copy('https://getcomposer.org/download/1.10.26/composer.phar', 'composer-setup.php');"
php -r "if (hash_file('sha256', 'composer-setup.php') === 'cbfe1f85276c57abe464d934503d935aa213494ac286275c8dfabfa91e3dbdc4') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
cp composer-setup.php /usr/local/bin/composer1

php -r "unlink('composer-setup.php');"

chmod +x /usr/local/bin/composer
chmod +x /usr/local/bin/composer1
chmod +x /usr/local/bin/composer2


touch $LEMP_FLAG_DIR/COMPOSER_INSTALLED