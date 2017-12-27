#!/bin/bash
. /usr/local/bin/sources

if [ ! -z $GIT_WEBSITE_REPO ]; then
  # clone git repo
  if [ ! -z $GIT_WEBSITE_BRANCH ]; then
    git clone -b $GIT_WEBSITE_BRANCH $GIT_WEBSITE_REPO /var/www_git
    GIT_EXIT_CODE=$?
  else
    git clone $GIT_WEBSITE_REPO /var/www_git
    GIT_EXIT_CODE=$?
  fi

  # do some stuff if git clone was successful
  if [[ $GIT_EXIT_CODE -eq 0 ]]; then
    echo "git pull successful of $GIT_WEBSITE_REPO:$GIT_WEBSITE_BRANCH"
  else
    echo "git pull failed of $GIT_WEBSITE_REPO:$GIT_WEBSITE_BRANCH"
  fi


fi
