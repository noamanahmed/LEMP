# LEMP Stack
This script will setup LEMP stack with additional utilites. There are alot of scripts already outthere which do this but this has been designed from the scratch to do minimal configuration and only do the basic installation,configuration which are sometimes done on daily basis.

## Who is this for?
This script is for the PHP,Python,NodeJS developers who don't want to use docker and want to setup VPS quickly. The whole code in repository is written by me to reducue the amount taken for daily tasks.

## Who is this NOT for?
This is my first bash script for automation. This is not built for pro level system admins as I am pretty sure they already have something for this.

## Requirements
- Ubuntu 20.04 (Working on 22)
- A FQDN pointing to the VPS Server IP to be used as hostname
- Root Level Access

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
- ProFTPD (Deprecreated)
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
- Kernel Tuning


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
Edit the install.sh script.
```sh
nano /opt/lemp/install.sh
```
Add your public key here. This step is must as in future you might loose access to your VM if you are accessing it using password based authentication as I will be soon disabling it and root login by default.
```sh
nano /opt/lemp/templates/ssh/.ssh/authorized_keys
nano /opt/lemp/templates/jailed_ssh/.ssh/authorized_keys
```
If you don't want to add your public key then you MUST remove my public key as it is currently in this repo. Its better to empty the files using this command
```sh
rm /opt/lemp/templates/ssh/.ssh/authorized_keys
rm /opt/lemp/templates/jailed_ssh/.ssh/authorized_keys
touch /opt/lemp/templates/ssh/.ssh/authorized_keys
touch /opt/lemp/templates/jailed_ssh/.ssh/authorized_keys
```
When done with the configuration run the installer.Change the default_site and example.com according to your settings.
```sh
/opt/lemp/install.sh -u default_site -h hostname.example.com
```
Now exit out of screen using Ctr/Cmd A + D. The script would install silently in the background. It generally took a 60 minute installation time with a 1GB Virmach VPS 

## Read Me First!
- Make sure the installer has completed to avoid any hiccups.
- Update the current bash shell using source ~/.profile or exit/logout and login again. If you are logging in again,then make sure you are using the correct SSH port which is NOT 22 but would have been changed to 6000.
- The installer outputs a log file location in /tmp path. Its best to review it and see if everything went well
- All most all of the sites (PHP,Python,NodeJS etc) comes with a basic setup to make sure everyhing went well 

## Creating your first PHP Site
Before creating your sites make sure that your domain name is pointing towards you IP with an A record.
Otherwise SSL certificate generation will fail and webserver would stop working alltogether

If everything went well then you can run this command to generate a new PHP site with SSL.Please replace the placeholder my_site with you rsite and your_first_name to a username without hyphens,underscores,digits etc. The user paremeter your_first_name is also your SSH/SFTP user as well as your $username field which you can later use in the helper scripts mentioned below.

```sh
create-site-php -u your_first_name -d my_site.com --php 7.4 --wordpress
create-site-php -u your_first_name -d my_site.com --php 7.4 --laravel
```

If everything went accordingly you should see your site running and a console message like this

```sh
Site Setup succssfull
URL : http://my_site.com
URL(SSL) : https://my_site.com
Complete Path : /home/your_first_name/www


WordPress user: your_first_name
WordPress password: random_password


MySQL Database Credentials
Database name: your_first_name
Database user: your_first_name
Database password: random_password

SFTP/SSH Details
Host: my_site.com
Port: 6000
Username: your_first_name
Password: random_password

```

By default the server public key gets added to each user and he can access any site as there specific user.

## Creating your Python,NodeJS Site (Reverse Proxy App)
Everything is almost similar to creating PHP site except that you need to pass a --port flag in the create-python-site or create-node-site script. Your Node JS app needs to listen on this port and this port must be available for you to use. I would recommend a port range from 11000 and incrementing by 10 for each of your sites. You need to pass an optional --mysql flag to generate credentials as mongodb even though is installed but still hasn't been tested yet

```sh
create-site-node -u your_first_name -d my_site.com --port 11000
create-site-python -u your_first_name -d my_site.com --port 11010
```

## Architecture Foundations
- Each site is created with its own jailed linux user.A jailed linux user has reduced previliges in case of possible hack
- $username in the documentation refers to the linux user and would have one site attached to it.
- If you ever want to delete a user, please use delete-site -u $username command to avoid any bugs

## Bugs
- /etc/passwd and /etc/group for jailed users gets misconfigured.
- List is quite long TBH :stuck_out_tongue_winking_eye:

## Code Structure
There are two main folders in this repository
- The bin folder contains all the utilty  and helper scripts to acheive automation for creating,deleting,restoring web sites and apps of different types.   
- The installer folder contains bash script for installing different types of linux softwares.
- The install.sh script is the main executable designed to be modified before running

## Work in Progress
- NoSQL database mongodb with a web base GUI tool
- Mail Server Setup (A complete alternative to iRedMail Setup)
- ELK Stack (Elasticsearch Logstash Kibana)
- Server Hardening
- Pushing backups to offsite storage as object storage etc 

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