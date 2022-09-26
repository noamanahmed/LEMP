#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"
source $DIR/../includes/helpers.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while getopts u:p: flag
do
    case "${flag}" in
        u) username=${OPTARG};;        
        p) password=${OPTARG};;        
    esac
done

if [ -z "$username" ]
then
    echo "Please provide a username using -u "
    exit
fi


if [ -z "$password" ]
then
    echo "Please provide a password using -p "
    exit
fi


#Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update
apt install jenkins -qqy

##Reset default username and password
systemctl stop jenkins
cp $template_path/jenkins/jenkins.service /lib/systemd/system/jenkins.service
mkdir -p /var/lib/jenkins/init.groovy.d
cp $template_path/jenkins/basic-security.groovy /var/lib/jenkins/init.groovy.d/
sed -i "s/{{username}}/$username/" /var/lib/jenkins/init.groovy.d/basic-security.groovy
sed -i "s/{{password}}/$password/" /var/lib/jenkins/init.groovy.d/basic-security.groovy
chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d
systemctl daemon-reload
systemctl start jenkins
sleep 10
rm -rf /var/lib/jenkins/init.groovy.d/basic-security.groovy
systemctl enable jenkins


nginx_vhost_file="/etc/nginx/apps-available/jenkins.conf"
nginx_vhost_enabled="/etc/nginx/apps-enabled/jenkins.conf"
cp $template_path/jenkins/vhost.conf $nginx_vhost_file

sed -i "s/{{domain}}/$HOSTNAME/" $nginx_vhost_file

ln -s $nginx_vhost_file $nginx_vhost_enabled
systemctl reload nginx


touch $LEMP_FLAG_DIR/JENKINS_INSTALLED

