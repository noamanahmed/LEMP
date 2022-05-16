#!/bin/bash


DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../ && pwd)/templates"


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


#Remove apache2 and its HTML directories
apt-get remove --purge apache2 -qqy

adduser --gecos "" --disabled-password --no-create-home  nginx 
groupadd web
groupadd sftp
usermod -a -G web nginx
#Install nginx
#apt install nginx -y
# Remove nginx if it exists
apt remove nginx -qqy
apt remove libgd3 -qqy
# Get Dev Dependencies for compiling nginx
apt install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev -qqy
# Get nginx source
rm -rf /tmp/nginx-build
rm -rf /usr/local/src/ngx_brotli
rm -rf /usr/local/src/redis2-nginx
mkdir -p /tmp/nginx-build
cd /tmp/nginx-build
wget http://nginx.org/download/nginx-1.18.0.tar.gz  -O nginx.tar.gz
tar -xvf nginx.tar.gz  
# Get brotli source
mkdir -p /usr/local/src
git clone --recursive https://github.com/google/ngx_brotli.git /usr/local/src/ngx_brotli
# Get Redis Source
git clone https://github.com/openresty/redis2-nginx-module /usr/local/src/redis2-nginx
# Get pagespeed source
NPS_VERSION=1.13.35.2-stable
wget -O- https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.tar.gz -O pagespeed.tar.gz
tar -xvf pagespeed.tar.gz
nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
nps_dir=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
cd "$nps_dir"
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget -O- ${psol_url} | tar -xz  # extracts to psol/
cp -rf /tmp/nginx-build/$nps_dir /usr/local/src/
cd /tmp/nginx-build
# Configure nginx to use these modules
cd nginx-1.18.0
DEBIAN_FRONTEND=noninteractive ./configure --with-cc=/usr/bin/gcc  --with-ld-opt=-static-libstdc++ --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module --add-module=/usr/local/src/ngx_brotli --add-module=/usr/local/src/redis2-nginx --add-module=/usr/local/src/$nps_dir
make -j$(cat /proc/cpuinfo | grep 'processor' | wc -l)
make install
cp $template_path/nginx/nginx.service /lib/systemd/system/nginx.service  
systemctl enable nginx


systemctl stop nginx
wget -O /etc/nginx/conf.d/blacklist.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blacklist.conf
wget -O /etc/nginx/conf.d/blockips.conf https://raw.githubusercontent.com/mariusv/nginx-badbot-blocker/master/blockips.conf
cp $template_path/nginx/nginx.conf /etc/nginx/nginx.conf
sed -i "s/{{cpu_cores}}/$(grep -c ^processor /proc/cpuinfo)/" /etc/nginx/nginx.conf
cp $template_path/nginx/htpasswd.users /etc/nginx/htpasswd.users
cp $template_path/nginx/htpasswd /etc/nginx/htpasswd
cp $template_path/nginx/performance.conf /etc/nginx/performance.conf
cp $template_path/nginx/proxypass.conf /etc/nginx/proxypass.conf

mkdir -p /etc/nginx/apps-enabled/
mkdir -p /etc/nginx/apps-available/
chown -R nginx:nginx /etc/nginx/apps-enabled/
chown -R nginx:nginx /etc/nginx/apps-available/
# mkdir -p /var/cache/nginx
# chown -R nginx:nginx /etc/nginx/*
# chown -R nginx:nginx /var/cache/nginx*

systemctl restart nginx
systemctl enable nginx





