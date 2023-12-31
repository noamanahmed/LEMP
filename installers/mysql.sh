#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


# Install mysql-server
apt install mysql-server -qqy
systemctl stop mysql
cp $template_path/mysql/10-lemp.cnf /etc/mysql/conf.d/
systemctl start mysql
systemctl enable mysql

# Create MYSQL Admin User

masterUser="noaman"
masterPassword="$(openssl rand -hex 12)"

mysql -ve "CREATE USER '$masterUser'@'localhost' IDENTIFIED BY '$masterPassword'"
mysql -ve "GRANT ALL PRIVILEGES ON *.* To '$masterUser'@'localhost'"
mysql -ve "GRANT SESSION_VARIABLES_ADMIN ON *.*  TO '$masterUser'@'localhost'";
mysql -ve "FLUSH PRIVILEGES;"


echo "Database Username : $masterUser"
echo "Database Password : $masterPassword"

touch $LEMP_FLAG_DIR/MYSQL_INSTALLED