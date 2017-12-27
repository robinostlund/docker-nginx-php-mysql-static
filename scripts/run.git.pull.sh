#!/bin/bash
. /usr/local/bin/sources.sh

cd /var/www_git
git pull -q

chown -R www-data:www-data /var/www_git
