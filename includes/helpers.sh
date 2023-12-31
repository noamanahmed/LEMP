#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}

is_mounted() {
    mount | awk -v DIR="$1" '{if ($3 == DIR) { exit 0}} ENDFILE{exit -1}'
}


php_versions_array=("8.2" "8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )

LEMP_HOSTNAME_USERNAME='default_site'
LEMP_LOCAL_LINUX_USER='noaman' ## Modify this to the username which you are using in Ubuntu GUI

LEMP_FLAG_DIR=/opt/lemp_installed
LEMP_CURRENT_VERSION=100


RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"


# Add Local flag
if [ -f "/opt/lemp_local_install" ]
then
    local=yes
    # Disable SSL certbot validation for local domain
    nossl=yes
fi