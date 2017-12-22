#!/bin/bash

. /usr/local/bin/sources.sh

set -x

# create folders
if [ ! -d /data/var/www/html ]; then
  mkdir -p /data/var/www/html
  mkdir -p /data/var/www/html/public_html
  mkdir -p /data/var/www/html/config
  cp /root/nginx/index.html /data/var/www/html/public_html/index.html
  cp /root/nginx/phpinfo.php /data/var/www/html/public_html/phpinfo.php
  chown -R www-data:www-data /data/var/www/html
fi

if [ ! -d /data/var/log/nginx ]; then
  mkdir -p /data/var/log/nginx
  chown www-data:www-data /data/var/log/nginx
fi

if [ ! -d /data/var/www/html/config ]; then
  mkdir -p /data/var/www/html/config
  chown www-data:www-data /data/var/www/html/config
fi

if [ ! -d /data/var/www/html/public_html ]; then
  mkdir -p /data/var/www/html/public_html
  chown -R www-data:www-data /data/var/www/html/public_html
fi

if [ ! -f /data/var/www/html/config/nginx.conf ]; then
  cp /root/nginx/nginx.conf /data/var/www/html/config/nginx.conf
  chown www-data:www-data /data/var/www/html/config/nginx.conf
fi

# enable x forwarded from if specified
if [ ! -z $NGINX_X_FORWARDED_FOR ]; then
  sed -i  "s/#real_ip_header/real_ip_header/g" /etc/nginx/sites-available/default
  sed -i  "s/#set_real_ip_from/set_real_ip_from/g" /etc/nginx/sites-available/default
fi

nginx -g "daemon off;"
