#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -u|--username)
      username="$2"
      shift
      ;;
    -d|--domain)
      domain="$2"
      shift
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument. $1 *\n"
      printf "***************************\n"
      exit 1
  esac  
  shift
done


if [ -z "$username" ]
then
    echo "Please provide a username using -u.If you are confused just set it to your first name"
    exit
fi


if [ -z "$hostname" ]
then
    echo "Please provide a hostname using -h "
    exit
fi

start=$(date +%s)

INSTALL_DIR=/tmp/lemp_$(openssl rand -hex 12)
mkdir -p $INSTALL_DIR
echo ""
echo "Installing Directory in $INSTALL_DIR"

echo "Updating Packages"
apt-get update -qqy > $INSTALL_DIR/apt_update.log 2>&1
apt-get upgrade -qqy > $INSTALL_DIR/apt_upgrade.log 2>&1
echo "Packages Updated"

echo "Changing Hostname to $hostname"
## Setup hostname
bash $DIR/installers/hostname.sh -h $hostname > $INSTALL_DIR/hostname1.sh.log 2>&1
hostname $hostname

echo "Installing PreReqs"
## Install prereqs
bash $DIR/installers/prereq.sh > $INSTALL_DIR/prereq.sh.log 2>&1


echo "Setting up SSH"
## Setting up SSH
bash $DIR/installers/ssh.sh > $INSTALL_DIR/ssh.sh.log 2>&1


echo "Installing Python"
## Install python
bash $DIR/installers/python.sh > $INSTALL_DIR/python.sh.log 2>&1

echo "Installing Fail2Ban,UFW and etc"
## Install Security related packages
bash $DIR/installers/fail2ban.sh > $INSTALL_DIR/fail2ban.sh.log 2>&1
bash $DIR/installers/ufw.sh > $INSTALL_DIR/ufw.sh.log 2>&1

echo "Installing LEMP Stack"
## Install LEMP
echo "Installing nginx"
bash $DIR/installers/nginx.sh > $INSTALL_DIR/nginx.sh.log 2>&1
##echo "Installing OpenResty(LuaJit on Steroids) Not Working properly"
##bash $DIR/installers/openresty.sh > $INSTALL_DIR/openresty.sh.log 2>&1
echo "Installing mysql"
bash $DIR/installers/mysql.sh > $INSTALL_DIR/mysql.sh.log 2>&1
echo "Installing php"
bash $DIR/installers/php.sh > $INSTALL_DIR/php.sh.log 2>&1
echo "LEMP Stack Installation completed!"


echo "Installing MERN Stack"
## Install MERN
# echo "Installing mongodb"
# bash $DIR/installers/mongodb.sh > $INSTALL_DIR/mongodb.sh.log 2>&1

echo "Installing Node Version Manager and setting up latest node"
bash $DIR/installers/nvm.sh > $INSTALL_DIR/nvm.sh.log 2>&1

echo "LEMP Stack Installation completed!"

## Install Misc
# echo "Installing Proftpd" (SFTP Preferred)
# bash $DIR/installers/proftpd.sh > $INSTALL_DIR/proftpd.sh.log 2>&1

echo "Installing LetsEncrypt SSL"
bash $DIR/installers/ssl.sh > $INSTALL_DIR/ssl.sh.log 2>&1

echo "Installing Redis"
bash $DIR/installers/redis.sh > $INSTALL_DIR/redis.sh.log 2>&1

echo "Installing Docker"
bash $DIR/installers/docker.sh > $INSTALL_DIR/docker.sh.log 2>&1

echo "Installing Composer"
bash $DIR/installers/composer.sh > $INSTALL_DIR/composer.sh.log 2>&1

echo "Installing Java"
bash $DIR/installers/java.sh > $INSTALL_DIR/java.sh.log 2>&1

echo "Installing MeiliSearch"
bash $DIR/installers/meilisearch.sh > $INSTALL_DIR/meilisearch.sh.log 2>&1

# echo "Installing Jenkins"
# bash $DIR/installers/jenkins.sh -u $username -p $username > $INSTALL_DIR/jenkins.sh.log 2>&1

## Install Jailkit
echo "Installing jailkit"
bash $DIR/installers/jailkit.sh > $INSTALL_DIR/jail.sh.log 2>&1

## Install misc scripts
echo "Installing wpcli,laravel installer and other misc tasks"
bash $DIR/installers/scripts.sh > $INSTALL_DIR/scripts.sh.log 2>&1

## Load new .profile
source ~/.profile

## Setup hostname site for phpmyadmin and other stuff
echo "Creating $hostname site with username $username"
bash $DIR/installers/create-site-php -u $username -d $hostname --php 8.1 > $INSTALL_DIR/$username-site.sh.log 2>&1

## Install phpmyadmin
echo "Installing phpmyadmin at $hostname"
bash $DIR/installers/phpmyadmin.sh -u $username > $INSTALL_DIR/$username-phpmyadmin.sh.log 2>&1

## Optional Postgres
echo "Installing postgres"
bash $DIR/installers/postgres.sh > $INSTALL_DIR/postgres.sh.log 2>&1

## Optional ELK Stack
# echo "Installing ELK Stack at $hostname"
# bash $DIR/installers/elk.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Kafka
# echo "Installing Kafka at $hostname"
# bash $DIR/installers/kafka.sh > $INSTALL_DIR/kafka.sh.log 2>&1

## Optional RabbitMQ
# echo "Installing RabbitMQ at $hostname"
# bash $DIR/installers/rabbitmq.sh -h $hostname > $INSTALL_DIR/rabbitmq.sh.log 2>&1

## Optional Netdata
echo "Installing NetData at $hostname"
bash $DIR/installers/netdata.sh -h $hostname > $INSTALL_DIR/netdata.sh.log 2>&1

## Optional Sentry(Consumes too much resources and W.I.P)
# echo "Installing sentry at $hostname"
# bash $DIR/installers/sentry.sh -h $hostname > $INSTALL_DIR/sentry.sh.log 2>&1


## Optional glitchtip (Consumes too much resources and W.I.P)
##echo "Installing Glitchtip at $hostname"
##bash $DIR/installers/glitchtip.sh -h $hostname > $INSTALL_DIR/glitchtip.sh.log 2>&1



echo "Installing monit"
## Setup monit to auto restart services
bash $DIR/installers/monit.sh > $INSTALL_DIR/monit.sh.log 2>&1

echo "Kernel Optimizations"
## Basic Level Kernel Optimizations
bash $DIR/installers/kernel.sh > $INSTALL_DIR/kernel.sh.log 2>&1

echo "apt autoremove"
## Removing any Extra Packages
apt autoremove -y > $INSTALL_DIR/apt_autoremove.log 2>&1

## Tools for Local Development Experience
## Optional Mailhog
# echo "Installing Mailhog at $hostname"
# ash $DIR/installers/mailhog.sh -h $hostname > $INSTALL_DIR/mailhog.sh.log 2>&1



end=$(date +%s)
echo "Time Taken to install: "
awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}'


