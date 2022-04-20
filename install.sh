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
apt-get update -qqy 2>&1 | tee $INSTALL_DIR/apt_update.log
apt-get upgrade -qqy 2>&1 | tee $INSTALL_DIR/apt_upgrade.log
echo "Packages Updated"

echo "Changing Hostname to $hostname"
## Setup hostname
bash hostname.sh -h $hostname 2>&1 | tee $INSTALL_DIR/hostname1.sh.log
hostname $hostname

echo "Installing PreReqs"
## Install prereqs
bash prereq.sh 2>&1 | tee $INSTALL_DIR/prereq.sh.log

echo "Installing Python"
## Install python
bash python.sh 2>&1 | tee $INSTALL_DIR/python.sh.log

echo "Installing Fail2Ban,UFW and etc"
## Install Security related packages
bash fail2ban.sh 2>&1 | tee $INSTALL_DIR/fail2ban.sh.log
bash ufw.sh 2>&1 | tee $INSTALL_DIR/ufw.sh.log

echo "Installing LEMP nginx,php and mysql"
## Install LEMP
bash nginx.sh 2>&1 | tee $INSTALL_DIR/nginx.sh.log
bash mysql.sh -u $username 2>&1 | tee $INSTALL_DIR/$username.sh.log
bash php.sh 2>&1 | tee $INSTALL_DIR/php.sh.log


## Install Misc
echo "Installing Proftpd"
bash proftpd.sh 2>&1 | tee $INSTALL_DIR/proftpd.sh.log
echo "Installing LetsEncrypt SSL"
bash ssl.sh 2>&1 | tee $INSTALL_DIR/ssl.sh.log
echo "Installing Redis User"
bash redis.sh 2>&1 | tee $INSTALL_DIR/redis.sh.log
echo "Installing Node Version Manager and setting up latest node"
bash nvm.sh 2>&1 | tee $INSTALL_DIR/nvm.sh.log
echo "Installing Redis"
bash redis.sh 2>&1 | tee $INSTALL_DIR/redis.sh.log
echo "Installing Docker"
bash docker.sh 2>&1 | tee $INSTALL_DIR/docker.sh.log
echo "Installing Composer"
bash composer.sh 2>&1 | tee $INSTALL_DIR/composer.sh.log
echo "Installing Java"
bash java.sh 2>&1 | tee $INSTALL_DIR/java.sh.log
echo "Installing MeiliSearch"
bash meilisearch.sh 2>&1 | tee $INSTALL_DIR/meilisearch.sh.log

#echo "Installing Jenkins(Work In Progress)"
#bash jenkins.sh 2>&1 | tee $INSTALL_DIR/jenkins.sh.log

## Install User jail
echo "Installing UserJail"
bash jail.sh 2>&1 | tee $INSTALL_DIR/jail.sh.log

## Install misc scripts
echo "Installing wpcli,laravel installer and other misc tasks"
bash scripts.sh 2>&1 | tee $INSTALL_DIR/scripts.sh.log

## Setup hostname site for phpmyadmin and other stuff
echo "Creating $hostname site with username $username"
bash create-site -u $username -d $hostname -p 8.1 2>&1 | tee $INSTALL_DIR/hostname_site.sh.log

## Install phpmyadmin
echo "Installing phpmyadmin at $hostname"
bash phpmyadmin.sh -u $username 2>&1 | tee $INSTALL_DIR/$username.sh.log

## Optional ELK Stack
##echo "Installing ELK Stack at $hostname"
##bash elk.sh -h $hostname 2>&1 | tee $INSTALL_DIR/$hostname.sh.log

## Optional Kafka
##echo "Installing Kafka at $hostname"
##bash kafka.sh 2>&1 | tee $INSTALL_DIR/kafka.sh.log

## Optional RabbitMQ
##echo "Installing RabbitMQ at $hostname"
##bash rabbitmq.sh -h $hostname 2>&1 | tee $INSTALL_DIR/$hostname.sh.log

## Optional Mailhog
##echo "Installing Mailhog at $hostname"
##bash mailhog.sh -h $hostname 2>&1 | tee $INSTALL_DIR/$hostname.sh.log

## Optional Netdata
##echo "Installing NetData at $hostname"
##bash netdata.sh -h $hostname 2>&1 | tee $INSTALL_DIR/$hostname.sh.log

## Optional glitchtip (requires docker) and there alot of bugs
##echo "Installing Glitchtip at $hostname"
##bash glitchtip.sh -h $hostname 2>&1 | tee $INSTALL_DIR/$hostname.sh.log

apt autoremove 2>&1 | tee $INSTALL_DIR/apt_autoremove.log


