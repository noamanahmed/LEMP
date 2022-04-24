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
bash installers/hostname.sh -h $hostname > $INSTALL_DIR/hostname1.sh.log 2>&1
hostname $hostname

echo "Installing PreReqs"
## Install prereqs
bash installers/prereq.sh > $INSTALL_DIR/prereq.sh.log 2>&1

echo "Installing Python"
## Install python
bash installers/python.sh > $INSTALL_DIR/python.sh.log 2>&1

echo "Installing Fail2Ban,UFW and etc"
## Install Security related packages
bash installers/fail2ban.sh > $INSTALL_DIR/fail2ban.sh.log 2>&1
bash installers/ufw.sh > $INSTALL_DIR/ufw.sh.log 2>&1

echo "Installing LEMP Stack"
## Install LEMP
echo "Installing nginx"
bash installers/nginx.sh > $INSTALL_DIR/nginx.sh.log 2>&1
##echo "Installing OpenResty(LuaJit on Steroids)"
##bash installers/openresty.sh > $INSTALL_DIR/openresty.sh.log 2>&1
echo "Installing mysql"
bash installers/mysql.sh > $INSTALL_DIR/$username.sh.log 2>&1
echo "Installing php"
bash installers/php.sh > $INSTALL_DIR/php.sh.log 2>&1
echo "LEMP Stack Installation completed!"


echo "Installing MERN Stack"
## Install MERN
echo "Installing mongodb"
bash installers/mongodb.sh > $INSTALL_DIR/mongodb.sh.log 2>&1
echo "Installing Node Version Manager and setting up latest node"
bash installers/nvm.sh > $INSTALL_DIR/nvm.sh.log 2>&1
echo "LEMP Stack Installation completed!"

## Install Misc
# echo "Installing Proftpd" (SFTP Preferred)
# bash installers/proftpd.sh > $INSTALL_DIR/proftpd.sh.log 2>&1
echo "Installing LetsEncrypt SSL"
bash installers/ssl.sh > $INSTALL_DIR/ssl.sh.log 2>&1
echo "Installing Redis"
bash installers/redis.sh > $INSTALL_DIR/redis.sh.log 2>&1
echo "Installing Docker"
bash installers/docker.sh > $INSTALL_DIR/docker.sh.log 2>&1
echo "Installing Composer"
bash installers/composer.sh > $INSTALL_DIR/composer.sh.log 2>&1
echo "Installing Java"
bash installers/java.sh > $INSTALL_DIR/java.sh.log 2>&1
echo "Installing MeiliSearch"
bash installers/meilisearch.sh > $INSTALL_DIR/meilisearch.sh.log 2>&1

#echo "Installing Jenkins(Work In Progress)"
#bash installers/jenkins.sh > $INSTALL_DIR/jenkins.sh.log 2>&1

## Install User jail
echo "Installing UserJail"
bash installers/jail.sh > $INSTALL_DIR/jail.sh.log 2>&1

## Install misc scripts
echo "Installing wpcli,laravel installer and other misc tasks"
bash installers/scripts.sh > $INSTALL_DIR/scripts.sh.log 2>&1

## Load new .profile
source ~/.profile

## Setup hostname site for phpmyadmin and other stuff
echo "Creating $hostname site with username $username"
bash installers/create-site -u $username -d $hostname -p 8.1 > $INSTALL_DIR/hostname_site.sh.log 2>&1

## Install phpmyadmin
echo "Installing phpmyadmin at $hostname"
bash installers/phpmyadmin.sh -u $username > $INSTALL_DIR/$username.sh.log 2>&1

## Optional ELK Stack
##echo "Installing ELK Stack at $hostname"
##bash installers/elk.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Kafka
##echo "Installing Kafka at $hostname"
#bash installers/kafka.sh > $INSTALL_DIR/kafka.sh.log 2>&1

## Optional RabbitMQ
##echo "Installing RabbitMQ at $hostname"
#bash installers/rabbitmq.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Mailhog
##echo "Installing Mailhog at $hostname"
#bash installers/mailhog.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional Netdata
##echo "Installing NetData at $hostname"
bash installers/netdata.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

## Optional glitchtip (requires docker) and there alot of bugs
##echo "Installing Glitchtip at $hostname"
##bash installers/glitchtip.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1

apt autoremove > $INSTALL_DIR/apt_autoremove.log 2>&1


