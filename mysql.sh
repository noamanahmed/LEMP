#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


# Install mysql-server

sudo apt install mysql-server -y
sudo systemctl start mysql.service

# Create MYSQL Admin User

masterUser="noaman"
masterPassword="$(openssl rand -hex 12)"

mysql -ve "CREATE USER '$masterUser'@'localhost' IDENTIFIED BY '$masterPassword'"
mysql -ve "GRANT ALL PRIVILEGES ON *.* To '$masterUser'@'localhost'"
mysql -ve "GRANT SESSION_VARIABLES_ADMIN ON *.*  TO '$masterUser'@'localhost'";
mysql -ve "FLUSH PRIVILEGES;"
