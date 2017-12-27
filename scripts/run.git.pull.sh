#!/bin/bash
. /usr/local/bin/sources

if [ ! -z $GIT_WEBSITE_REPO ]; then
  # clone git repo
  if [ ! -z $GIT_WEBSITE_BRANCH ]; then
    git fetch --all
    git reset --hard origin/$GIT_WEBSITE_BRANCH
    #git clone -b $GIT_WEBSITE_BRANCH $GIT_WEBSITE_REPO /var/www_git
    #GIT_EXIT_CODE=$?
  else
    git fetch --all
    git reset --hard origin/master
    #GIT_EXIT_CODE=$?
  fi
fi
