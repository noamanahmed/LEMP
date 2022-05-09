exists()
{
  command -v "$1" >/dev/null 2>&1
}

php_versions()
{
  php_versions_array=("8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )
}

#Servername
#cat  /etc/nginx/sites-available/angular1.conf  | grep -m1 -Poe 'server_name \K[^; ]+'

# if id -nGz "$USER" | grep -qzxF "$GROUP"
# then
#     echo User \`$USER\' belongs to group \`$GROUP\'
# else
#     echo User \`$USER\' does not belong to group \`$GROUP\'
# fi


# Add Local flag
if [ -f "/opt/lemp_local_install" ]
then
    local=yes
    # Disable SSL certbot validation for local domain
    nossl=yes
fi