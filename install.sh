#!/bin/bash


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


while getopts h:u: flag
do
    case "${flag}" in
        h) hostname=${OPTARG};;        
        u) username=${OPTARG};;
    esac
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
bash hostname.sh -h $hostname > $INSTALL_DIR/hostname1.sh.log 2>&1
hostname $hostname

echo "Installing PreReqs"
## Install prereqs
bash prereq.sh > $INSTALL_DIR/prereq.sh.log 2>&1

echo "Installing Python"
## Install python
bash python.sh > $INSTALL_DIR/python.sh.log 2>&1

echo "Installing Fail2Ban,UFW and etc"
## Install Security related packages
bash fail2ban.sh > $INSTALL_DIR/fail2ban.sh.log 2>&1
bash ufw.sh > $INSTALL_DIR/ufw.sh.log 2>&1

echo "Installing LEMP Stack"
## Install LEMP
echo "Installing nginx"
bash nginx.sh > $INSTALL_DIR/nginx.sh.log 2>&1
echo "Installing mysql"
bash mysql.sh -u $username > $INSTALL_DIR/$username.sh.log 2>&1
echo "Installing php"
bash php.sh > $INSTALL_DIR/php.sh.log 2>&1
echo "LEMP Stack Installation completed!"

## Install Misc
echo "Installing Proftpd"
bash proftpd.sh > $INSTALL_DIR/proftpd.sh.log 2>&1
echo "Installing LetsEncrypt SSL"
bash ssl.sh > $INSTALL_DIR/ssl.sh.log 2>&1
echo "Installing Redis User"
bash redis.sh > $INSTALL_DIR/redis.sh.log 2>&1
echo "Installing Node Version Manager and setting up latest node"
bash nvm.sh > $INSTALL_DIR/nvm.sh.log 2>&1
echo "Installing Redis"
bash redis.sh > $INSTALL_DIR/redis.sh.log 2>&1
echo "Installing Docker"
bash docker.sh > $INSTALL_DIR/docker.sh.log 2>&1
echo "Installing Composer"
bash composer.sh > $INSTALL_DIR/composer.sh.log 2>&1
echo "Installing Java"
bash java.sh > $INSTALL_DIR/java.sh.log 2>&1
echo "Installing MeiliSearch"
bash meilisearch.sh > $INSTALL_DIR/meilisearch.sh.log 2>&1

#echo "Installing Jenkins(Work In Progress)"
#bash jenkins.sh > $INSTALL_DIR/jenkins.sh.log 2>&1

## Install User jail
echo "Installing UserJail"
bash jail.sh > $INSTALL_DIR/jail.sh.log 2>&1

## Install misc scripts
echo "Installing wpcli,laravel installer and other misc tasks"
bash scripts.sh > $INSTALL_DIR/scripts.sh.log 2>&1

## Load new .profile
source ~/.profile

## Setup hostname site for phpmyadmin and other stuff
echo "Creating $hostname site with username $username"
bash create-site -u $username -d $hostname -p 8.1 > $INSTALL_DIR/hostname_site.sh.log 2>&1

## Install phpmyadmin
echo "Installing phpmyadmin at $hostname"
bash phpmyadmin.sh -u $username > $INSTALL_DIR/$username.sh.log 2>&1

## Optional ELK Stack
##echo "Installing ELK Stack at $hostname"
##bash elk.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Kafka
##echo "Installing Kafka at $hostname"
bash kafka.sh > $INSTALL_DIR/kafka.sh.log 2>&1

## Optional RabbitMQ
##echo "Installing RabbitMQ at $hostname"
bash rabbitmq.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Mailhog
##echo "Installing Mailhog at $hostname"
bash mailhog.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Netdata
##echo "Installing NetData at $hostname"
bash netdata.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional glitchtip (requires docker) and there alot of bugs
##echo "Installing Glitchtip at $hostname"
##bash glitchtip.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

apt autoremove > $INSTALL_DIR/apt_autoremove.log 2>&1


