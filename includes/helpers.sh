exists()
{
  command -v "$1" >/dev/null 2>&1
}

php_versions()
{
  php_versions_array=("8.1" "8.0" "7.4" "7.3" "7.2" "7.1" "7.0" "5.6" )
}


LEMP_HOSTNAME_USERNAME='default_site'
LEMP_LOCAL_LINUX_USER='noaman' ## Modify this to the username which you are using in Ubuntu GUI
#Servername
#cat  /etc/nginx/sites-available/angular1.conf  | grep -m1 -Poe 'server_name \K[^; ]+'

# if id -nGz "$USER" | grep -qzxF "$GROUP"
# then
#     echo User \`$USER\' belongs to group \`$GROUP\'
# else
#     echo User \`$USER\' does not belong to group \`$GROUP\'
# fi
#VS Code Fix
#cp /usr/share/code/code /var/www/usr/share/code/
#cp /opt/amdgpu/lib/x86_64-linux-gnu/libdrm.so.2 /var/www/lib/x86_64-linux-gnu/
#cp /opt/amdgpu/lib/x86_64-linux-gnu/libgbm.so.1 /var/www/lib/x86_64-linux-gnu/
# Nextlcoud nginx block
# location / {
#         #rewrite ^ /index.php$uri;
#         # First attempt to serve request as file, then
#         # as directory, then fall back to displaying a 404.
#         # try_files $uri /index.php$uri$is_args$args;
#         rewrite ^/index.php/(.*) /$1  permanent;
#            #rewrite ^/index.php/(.*) /index.php$1;      
#            #try_files $uri $uri/ =404;
#            #index index.php;
#             try_files $uri $uri/ /index.php;
#                 rewrite ^ /index.php last;

# }
# 'front_controller_active' => true,
# nextcloud Config.php
 
# Add Local flag
if [ -f "/opt/lemp_local_install" ]
then
    local=yes
    # Disable SSL certbot validation for local domain
    nossl=yes
fi