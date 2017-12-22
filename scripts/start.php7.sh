#!/bin/bash

. /usr/local/bin/sources.sh

set -x

sed -i "s/memory_limit.*$/memory_limit = $PHP_MEM/g" /etc/php/7.0/fpm/php.ini

mkdir /run/php
php-fpm7.0 --nodaemonize
