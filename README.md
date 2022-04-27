# LEMP Stack
This script will setup LEMP stack with additional utilites. There are alot of scripts already outthere which do this but this has been designed from the scratch to do minimal configuration and only do the basic installation,configuration which are sometimes done on daily basis.

## Requirements
- Ubuntu 20.04
- A FQDN pointing to the VPS Server IP to be used as hostname
- Root Level Access

## Installation Steps
```sh
sudo apt-get update
```
Setup Screen and Git
```sh
sudo apt-get install screen git -y
```
Use Screen to install the LEMP Stack
```sh
screen -S installer
```
Clone the repo at the specified path (The path is important!)
```sh
sudo git clone https://gitlab.com/noamanahmed/lemp /opt/lemp
```
Edit the install.sh script (Default should be good for most people)
```sh
nano /opt/lemp/install.sh
```
When done with the configuration run the installer.Change the default_site and example.com according to your settings.
```sh
/opt/lemp/install.sh -u default_site -h hostname.example.com
```
Now exit out of screen using Ctr/Cmd A + D. The script would install silently in the backgroun
## Features
- PHP Version 5.6,7.0,7.1,7.2,7.3,7.4,8.0,8.1
- Python Versions 2.7,3.5,3.6,3.7,3.8,3.9,3.10
- MYSQL Version 8.0
- Postgres Version 14
- MongoDB
- Nginx
- FastCGI Caching for PHP-FPM
- LetsEncrypt SSL
- NVM (Node Version Manager)
- Jailed Users (Chroot)
- Composer
- WP-CLI
- Redis
- ProFTPD
- Docker
- Java
- MeiliSearch
- PHPMyadmin
- Apache Kafka
- Rabbit MQ
- NetData
- Mailhog
- Fail2Ban
- UFW

## Work in Progress
- Mail Server Setup (A complete alternative to iRedMail Setup)
- ELK Stack (Elasticsearch Logstash Kibana)
- Server Hardening
- Pushing backups to offsite storage as object storage etc 
- Working on writing usage for the utility scripts

## In Future
- Compile nginx from source to allow brotli,redis and work on page speed
- Prometheus (Netdata can be used for the timebeing)
- Zabbix
- Chef
- Ansible
- Puppet

## Utility Scripts
```sh
backup-site -u $username
```
Backups your site to /backups
```sh
clear-cache -u $username
```
Clears fastcgi cache for nginx.
```sh
create-app-user
```
W.I.P Ignore this
```sh
create-jail-user -u $username 
```
Jails a user 
```sh
create-linux-user -u $username -p $password
```
Helper script to create a linux user
```sh
create-mysql-db
```
Helper script to create mysql database with user
```sh
create-site-node -u $username -d example.com --port $available_port
```
creates a node application with reverse proxy using nginx proxy pass. 
```sh
create-site-php -u $username -d example.com --php 7.4 --wordpress
create-site-php -u $username -d example.com --php 7.4 --laravel
```
creates a PHP application using php-fpm and mysql
```sh
create-site-python -u $username -d example.com --port $available_port
```
creates a python application with reverse proxy using nginx proxy pass
```sh
create-site-react -u $username -d example.com
```
creates a react front end site with node installed with nvm. It comes with a basic react to get going.
```sh
create-site-svelte -u $username -d example.com
```
(W.I.P) Creates a svelete front end site with node installed with nvm
```sh
create-site-vue -u $username -d example.com
```
(W.I.P) Creates a vue front end site with node installed with nvm
```sh
create-user-angular -u $username -d example.com
```
(W.I.P) Creates a vue front end site with node installed with nvm
```sh
create-user-mysql-db
```
(Ignore this)
```sh
create-wp-user
```
(W.I.P) Resets wp user noaman by deleting accounta and creating new.
```sh
delete-backup -u $username -n backup_name
```
Delete a backup for a site
```sh
delete-mysql-db -d $database_name
```
Drop MySQL database
```sh
delete-site -u $username
```
Removes a site completely from system.
```sh
delete-wp-plugin -u $username -p $plugin_name
```
Removes wordpress plugin
```sh
disable-site -u $username
```
Disables nginx vhost by removing symlinks
```sh
enable-site -u $username
```
Enables nginx vhost by adding symlinks
```sh
fix-permissions -u $username
```
Fixes permissions for sites to remove any permission related issues
```sh
install-nvm -u $username
```
Installes Node Version Manager(N.V.M) for a site 
```sh
install-wp -u $username -d example.com
```
Installs wordpress in a site
```sh
install-wp-plugin -u $username -p $plugin -a yes
```
Installs wordpress plugins in a site. Add -a flag with any value to auto activate it too.
```sh
jail-binary -b $binary
```
Helper script to allow a binary to all jailed user.
```sh
jail-user -u $username
```
Move user to a jail
```sh
logrotate-site -u $username -e $enable -d $disable 
```
Enable/Disable log rotation for a site specific logs 
```sh
nvm-user -u $username -c $command
```
Run shell commands for a specific user with NVM already bootstrapped.You can use this to run npm install and other commands.
```sh
restore-site -u $username
```
Restores a site from a backup
```sh
toggle-node -u $username -v $version
```
(W.I.P) Change node version for a user
```sh
toggle-php -u $username -p $php_version
```
Changes php version for web and CLI for a site
```sh
toggle-python -u $username -p $python_version
```
Changes php version for CLI and auto restarts systemd script
```sh
update-jail
```
(WIP) Updates jail
```sh
update-lemp
```
A quick bash command to update to the latest version of this repo