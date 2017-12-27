#!/bin/bash

. /usr/local/bin/sources.sh

set -x

# create log folder
if [ ! -d /data/var/log/nginx ]; then
  mkdir -p /data/var/log/nginx
  chown www-data:www-data /data/var/log/nginx
fi

# checkout git repo if specified
if [ ! -z $GIT_WEBSITE_REPO ]; then
  # create ssh folder and add some settings to it
  mkdir /root/.ssh
  chmod 600 /root/.ssh
  echo "StrictHostKeyChecking no" > /root/.ssh/config
  echo "UserKnownHostsFile=/dev/null" >> /root/.ssh/config
  chmod 600 /root/.ssh/config

  # copy nginx site template
  cp /root/nginx/site-git.conf /etc/nginx/sites-available/default

  # create git key folder
  if [ ! -d /data/git_key ]; then
    mkdir -p /data/git_key
  fi

  # check if we have ssh key
  if [ -f /data/git_key/id_rsa ]; then
    cp /data/git_key/id_rsa /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    chown root:root /root/.ssh/id_rsa
  fi

  # clone git repo
  if [ ! -z $GIT_WEBSITE_BRANCH ]; then
    git clone -b $GIT_WEBSITE_BRANCH $GIT_WEBSITE_REPO /var/www_git
    GIT_EXIT_CODE=$?
  else
    git clone $GIT_WEBSITE_REPO /var/www_git
    GIT_EXIT_CODE=$?
  fi

  # create nginx config directory if not exists
  if [ ! -d /var/www_git/config ]; then
    mkdir -p /var/www_git/config
    chown www-data:www-data /var/www_git/config
  fi

  # create nginx config if not exists in git repo from template
  if [ ! -f /var/www_git/config/nginx.conf ]; then
    cp /root/nginx/nginx.conf /var/www_git/config/nginx.conf
    chown www-data:www-data /var/www_git/config/nginx.conf
  fi

  # do some stuff if git clone was successful
  if [[ $GIT_EXIT_CODE -eq 0 ]]; then
    if [ -d /var/www_git/public_html ]; then
      chown -R www-data:www-data /var/www_git/public_html
    fi

    # enable git pull cronjob if specified
    if [ ! -z $GIT_WEBSITE_CRON_PULL ]; then
      echo "*/10 * * * * root /usr/local/bin/run.git.pull.sh" > /etc/cron.d/gitpull
    fi
  fi

else
  # copy nginx site template
  cp /root/nginx/site.conf /etc/nginx/sites-available/default

  if [ ! -d /data/var/www/html ]; then
    mkdir -p /data/var/www/html
    mkdir -p /data/var/www/html/config
    cp /root/nginx/index.html /data/var/www/html/public_html/index.html
    cp /root/nginx/phpinfo.php /data/var/www/html/public_html/phpinfo.php
    chown -R www-data:www-data /data/var/www/html
  fi

  if [ ! -d /data/var/www/html/config ]; then
    mkdir -p /data/var/www/html/config
    chown www-data:www-data /data/var/www/html/config
  fi

  if [ ! -f /data/var/www/html/config/nginx.conf ]; then
    cp /root/nginx/nginx.conf /data/var/www/html/config/nginx.conf
    chown www-data:www-data /data/var/www/html/config/nginx.conf
  fi

  if [ ! -d /data/var/www/html/public_html ]; then
    mkdir -p /data/var/www/html/public_html
    chown -R www-data:www-data /data/var/www/html/public_html
  fi

fi

# enable x forwarded from if specified
if [ ! -z $NGINX_X_FORWARDED_FOR ]; then
  sed -i  "s/#real_ip_header/real_ip_header/g" /etc/nginx/sites-available/default
  sed -i  "s/#set_real_ip_from/set_real_ip_from/g" /etc/nginx/sites-available/default
fi

nginx -g "daemon off;"
