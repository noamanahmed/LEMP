# LEMP Stack
This script will setup LEMP stack with additional utilites. There are alot of scripts already outthere which do this but this has been designed from the scratch to do minimal configuration and only do the basic installation,configuration which are somtmes done on daily basis.

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
- PHP Version 7.3,7.4,8.0,8.1
- MYSQL Version 8.0
- Nginx
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
- Utility Scripts to create python,node backend with SSL using nginx reverse proxy
- Utility Scripts to create react,angular,vue.js,svelte frontend with SSL using nginx reverse proxy
- Jenkins(Looking to Automate Installation without using GUI)
- Sentry Open Source
- Glitchtip (Alternative to Sentry)
- Mail Server Setup (A complete alternative to iRedMail Setup)
- ELK Stack (Elasticsearch Logstash Kibana)
- Server Hardening
- Reducing Disk Usage for Jailed Users
- Kernel Optimization for fast nginx
- Pushing backups to offsite storage as object storage etc 

## In Future
- Prometheus (Netdata can be used for the timebeing)
- Zabbix
- Chef
- Ansible
- Puppet

## Utility Scripts

```sh
delete-user
```sh

```sh
clear-cache
```sh

```sh
update-jail
```sh

```sh
create-user-svelte
```sh

```sh
restore-user
```sh

```sh
create-db
```sh

```sh
create-user-vue
```sh

```sh
delete-backup
```sh

```sh
create-user-react
```sh

```sh
install-wp
```sh

```sh
create-jail-user
```sh

```sh
backup-user
```sh

```sh
toggle-php
```sh

```sh
create-wp-user
```sh

```sh
install-wp-plugin
```sh

```sh
create-user-db
```sh

```sh
create-user-angular
```sh

```sh
jail-user
```sh

```sh
disable-site
```sh

```sh
create-app-user
```sh

```sh
delete-db
```sh

```sh
create-user-node
```sh

```sh
enable-site
```sh

```sh
fix-permissions
```sh

```sh
create-user
```sh

```sh
update-lemp
```sh

```sh
create-user-python
```sh

```sh
create-linux-user
```sh

```sh
logrotate-user
```sh

```sh
delete-wp-plugin
```sh


