#!/bin/bash
. /usr/local/bin/sources

if [ ! -z $GIT_WEBSITE_REPO ]; then
  # clone git repo
  if [ ! -z $GIT_WEBSITE_BRANCH ]; then
    cd /var/www_git
    git pull -q origin $GIT_WEBSITE_BRANCH
  else
    cd /var/www_git
    git pull -q origin master
  fi
  chown -R www-data:www-data /var/www_git
fi
