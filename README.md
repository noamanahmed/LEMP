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


## Installation

The installation instructions have been moved to its own wiki page called 
[Installation](../../wiki/Installation)

## Quick Start

The installation instructions have been moved to its own wiki page called 
[QuickStart](../../wiki/QuickStart)


## Work in Progress
- Compile nginx from source to allow brotli,redis and work on page speed
- Server Hardening
- Pushing backups to offsite storage as object storage etc 
- Support for other programming languages like Go,Rust,.Net etc
- Create restart-site script
- Create Drupal,OpenCart etc installer
