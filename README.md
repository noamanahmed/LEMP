# LEMP Stack
This script will setup LEMP stack with additional utilites. There are alot of scripts already out there which do this but this has been designed from the scratch to do minimal configuration and only do the basic installation,configuration which are sometimes done on daily basis.

## Who is this for?
This script is for the PHP,Python,NodeJS developers who don't want to use docker and want to setup VPS quickly. The whole code in repository is written by me to reduce the amount taken for daily tasks.

## Who is this NOT for?
This is my first bash script for automation. This is not built for pro level system admins as I am pretty sure they already have something for this.

## Requirements
- Ubuntu 20.04 (Working on 22)
- A FQDN pointing to the VPS Server IP to be used as hostname
- Root Level Access

## Features
- PHP Version 5.6,7.0,7.1,7.2,7.3,7.4,8.0,8.1
- Python Versions 2.7,3.5,3.6,3.7,3.8,3.9,3.10
- Node Versions 4,6,8,10,12,14,16,18
- Uptime Monitoring with Uptime Robot
- Slack Notification (using Webhook)
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
- Monit
- Zabbix Agent Setup
- Kernel Tuning



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




## Work in Progress
- ELK Stack (Elasticsearch Logstash Kibana)
- Server Hardening
- Pushing backups to offsite storage as object storage etc 

## In Future
- Compile nginx from source to allow brotli,redis and work on page speed
- Prometheus (Netdata can be used for the timebeing)
- Ansible
