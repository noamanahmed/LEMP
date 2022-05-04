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
        -h|--hostname)
            hostname="$2"
            shift
        ;;
        --without_security)
            without_security=yes
        ;;
        --without_python)
            without_python=yes
        ;;
        --without_nginx)
            without_nginx=yes
        ;;
        --without_mysql)
            without_mysql=yes
        ;;
        --without_php)
            without_php=yes
        ;;
        --without_mongodb)
            without_mongodb=yes
        ;;
        --without_mongodb_express)
            without_mongodb_express=yes
        ;;
        --without_nvm)
            without_nvm=yes
        ;;
        --without_proftpd)
            without_proftpd=yes
        ;;
        --without_letsencrypt)
            without_letsencrypt=yes
        ;;
        --without_redis)
            without_redis=yes
        ;;
        --without_docker)
            without_docker=yes
        ;;
        --without_composer)
            without_composer=yes
        ;;
        --without_java)
            without_java=yes
        ;;
        --without_meilisearch)
            without_meilisearch=yes
        ;;
        --with_jenkins)
            with_jenkins=yes
        ;;
        --without_jailkit)
            without_jailkit=yes
        ;;
        --without_scripts)
            without_scripts=yes
        ;;
        --without_hostname_site)
            without_hostname_site=yes
        ;;
        --without_phpmyadmin)
            without_phpmyadmin=yes
        ;;
        --without_postgres)
            without_postgres=yes
        ;;
        --without_pgadmin)
            without_pgadmin=yes
        ;;
        --with_elk)
            with_elk=yes
        ;;
        --with_kafka)
            with_kafka=yes
        ;;
        --with_rabbitmq)
            with_rabbitmq=yes
        ;;
        --with_netdata)
            with_netdata=yes
        ;;
        --with_sentry)
            with_sentry=yes
        ;;
        --with_glitchtip)
            with_glitchtip=yes
        ;;
        --without_monit)
            without_monit=yes
        ;;
        --without_kernel)
            without_kernel=yes
        ;;
        --with_mailhog)
            with_mailhog=yes
        ;;
        --with_mailserver)
            with_mailserver=yes
        ;;
        --slack_notification_webhook)
            slack_notification_webhook="$2"
            shift
        ;;
        --uptime_robot_key)
            uptime_robot_key="$2"
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

# Setup notification and monitor uptop so that we can also set monitoring for the hostdomain itself
if [ ! -z "$slack_notification_webhook" ]
then
    echo $slack_notification_webhook > /etc/monit/slack-url
fi


if [ ! -z "$uptime_robot_key" ]
then
    touch /opt/uptime_robot.key
    echo $uptime_robot_key > /opt/uptime_robot.key
fi

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

if [ -z "$without_python" ]
then
    echo "Installing Python"
    ## Install python
    bash $DIR/installers/python.sh > $INSTALL_DIR/python.sh.log 2>&1
fi

if [ -z "$without_security" ]
then
    echo "Installing Fail2Ban,UFW and etc"
    ## Install Security related packages
    bash $DIR/installers/fail2ban.sh > $INSTALL_DIR/fail2ban.sh.log 2>&1
    bash $DIR/installers/ufw.sh > $INSTALL_DIR/ufw.sh.log 2>&1
fi

echo "Installing LEMP Stack"
## Install LEMP
if [ -z "$without_nginx" ]
then
    echo "Installing nginx"
    bash $DIR/installers/nginx.sh > $INSTALL_DIR/nginx.sh.log 2>&1
fi

##echo "Installing OpenResty(LuaJit on Steroids) Not Working properly"
##bash $DIR/installers/openresty.sh > $INSTALL_DIR/openresty.sh.log 2>&1
if [ -z "$without_mysql" ]
then
    echo "Installing mysql"
    bash $DIR/installers/mysql.sh > $INSTALL_DIR/mysql.sh.log 2>&1
fi

if [ -z "$without_php" ]
then
    echo "Installing php"
    bash $DIR/installers/php.sh > $INSTALL_DIR/php.sh.log 2>&1
fi

echo "LEMP Stack Installation completed!"


echo "Installing MERN Stack"
## Install MERN
if [ -z "$without_mongodb" ]
then
    echo "Installing mongodb"
    bash $DIR/installers/mongodb.sh > $INSTALL_DIR/mongodb.sh.log 2>&1
fi

if [ -z "$without_nvm" ]
then
    echo "Installing Node Version Manager and setting up latest node"
    bash $DIR/installers/nvm.sh > $INSTALL_DIR/nvm.sh.log 2>&1
fi
echo "MEAN Stack Installation completed!"

# if [ -z "$without_proftpd" ]
# then
#     ## Install Misc
#     # echo "Installing Proftpd" (SFTP Preferred)
#     # bash $DIR/installers/proftpd.sh > $INSTALL_DIR/proftpd.sh.log 2>&1
# fi

if [ -z "$without_letsencrypt" ]
then
    echo "Installing LetsEncrypt SSL"
    bash $DIR/installers/ssl.sh > $INSTALL_DIR/ssl.sh.log 2>&1
fi

if [ -z "$without_redis" ]
then
    echo "Installing Redis"
    bash $DIR/installers/redis.sh > $INSTALL_DIR/redis.sh.log 2>&1
fi

if [ -z "$without_docker" ]
then
    echo "Installing Docker"
    bash $DIR/installers/docker.sh > $INSTALL_DIR/docker.sh.log 2>&1
fi

if [ -z "$without_composer" ]
then
    echo "Installing Composer"
    bash $DIR/installers/composer.sh > $INSTALL_DIR/composer.sh.log 2>&1
fi

if [ -z "$without_java" ]
then
    echo "Installing Java"
    bash $DIR/installers/java.sh > $INSTALL_DIR/java.sh.log 2>&1
fi

if [ -z "$without_meilisearch" ]
then
    echo "Installing MeiliSearch"
    bash $DIR/installers/meilisearch.sh > $INSTALL_DIR/meilisearch.sh.log 2>&1
fi

if [ ! -z "$with_jenkins" ]
then
    echo "Installing Jenkins"
    bash $DIR/installers/jenkins.sh -u $username -p $username > $INSTALL_DIR/jenkins.sh.log 2>&1
fi


if [ -z "$without_scripts" ]
then
    ## Install misc scripts
    echo "Installing wpcli,laravel installer and other misc tasks"
    bash $DIR/installers/scripts.sh > $INSTALL_DIR/scripts.sh.log 2>&1
fi

if [ -z "$without_jailkit" ]
then
    ## Install Jailkit
    echo "Installing jailkit"
    bash $DIR/installers/jailkit.sh > $INSTALL_DIR/jail.sh.log 2>&1
fi


## Load new .profile
source ~/.profile

## Setup hostname site for phpmyadmin and other stuff
if [ -z "$without_hostname_site" ]
then
    echo "Creating $hostname site with username $username"
    create-site-php -u $username -d $hostname --php 8.1 > $INSTALL_DIR/$username-site.sh.log 2>&1
fi

if [ -z "$without_phpmyadmin" ]
then
    ## Install phpmyadmin
    echo "Installing phpmyadmin at $hostname"
    bash $DIR/installers/phpmyadmin.sh -u $username > $INSTALL_DIR/$username-phpmyadmin.sh.log 2>&1
fi

if [ -z "$without_postgres" ]
then
    ## Optional Postgres
    echo "Installing postgres"
    bash $DIR/installers/postgres.sh > $INSTALL_DIR/postgres.sh.log 2>&1
fi

if [ ! -z "$with_elk" ]
then
    ## Optional ELK Stack
    echo "Installing ELK Stack at $hostname"
    bash $DIR/installers/elk.sh -h $hostname > $INSTALL_DIR/$hostname.sh.log 2>&1
fi

if [ ! -z "$with_kafka" ]
then
    # Optional Kafka
    echo "Installing Kafka at $hostname"
    bash $DIR/installers/kafka.sh > $INSTALL_DIR/kafka.sh.log 2>&1
fi

if [ ! -z "$with_rabbitmq" ]
then
    ## Optional RabbitMQ
    echo "Installing RabbitMQ at $hostname"
    bash $DIR/installers/rabbitmq.sh -h $hostname > $INSTALL_DIR/rabbitmq.sh.log 2>&1
fi

if [ ! -z "$with_netdata" ]
then
    ## Optional Netdata
    echo "Installing NetData at $hostname"
    bash $DIR/installers/netdata.sh -h $hostname > $INSTALL_DIR/netdata.sh.log 2>&1
fi

if [ ! -z "$with_sentry" ]
then
    ## Optional Sentry(Consumes too much resources and W.I.P)
    echo "Installing sentry at $hostname"
    bash $DIR/installers/sentry.sh -h $hostname > $INSTALL_DIR/sentry.sh.log 2>&1
fi

if [ ! -z "$with_glitchtip" ]
then
    ## Optional glitchtip (Consumes too much resources and W.I.P)
    echo "Installing Glitchtip at $hostname"
    bash $DIR/installers/glitchtip.sh -h $hostname > $INSTALL_DIR/glitchtip.sh.log 2>&1
fi

if [ -z "$without_monit" ]
then
    ## Setup monit to auto restart services and send notifications
    echo "Installing monit"
    bash $DIR/installers/monit.sh -u $username -p $username > $INSTALL_DIR/monit.sh.log 2>&1
fi

if [ -z "$without_kernel" ]
then
    ## Basic Level Kernel Optimizations
    echo "Kernel Optimizations"
    bash $DIR/installers/kernel.sh > $INSTALL_DIR/kernel.sh.log 2>&1
fi

echo "Running apt autoremove to remove extra packages"
## Removing any Extra Packages
apt autoremove -y > $INSTALL_DIR/apt_autoremove.log 2>&1

## Tools for Local Development Experience

if [ ! -z "$with_mailhog" ] 
then
    ## Optional Mailhog
    echo "Installing Mailhog at $hostname"
    ash $DIR/installers/mailhog.sh -h $hostname > $INSTALL_DIR/mailhog.sh.log 2>&1
fi

if [ -z "$without_mongodb" ] && [ -z "$without_mongodb_express" ]
then
    ## Optional install mongodb express gui tool for mongodb
    echo "Installing mongodb express"
    bash $DIR/installers/mongodb_express.sh > $INSTALL_DIR/mongodb_express.sh.log 2>&1
fi

if [ -z "$without_postgres" ] && [ -z "$without_pgadmin" ]
then
    ## Optional install postgres express gui tool for postgres
    echo "Installing pgadmin"
    bash $DIR/installers/pgadmin.sh > $INSTALL_DIR/pgadmin.sh.log 2>&1
fi


if [ ! -z "$with_mailserver" ]
then
    ## Optional install postgres express gui tool for postgres
    echo "Installing Mail Server(Postfix,Dovecot,Postfixadmin,"
    bash $DIR/installers/mailserver.sh > $INSTALL_DIR/mailserver.sh.log 2>&1
fi




end=$(date +%s)
seconds=$(echo "$end - $start" | bc)
echo "Time Taken to install: "
awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}'

bash slack-notification -u $username -d $domain -m "Installation completed: $hostname Time Taken: $seconds " --success

