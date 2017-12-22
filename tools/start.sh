#!/bin/bash
docker run -dt \
    --name httptest \
    --hostname httptest \
    -p 8080:80 \
    -v /tmp/test:/data \
    -e MYSQL_DB_NAME=my_db_name \
    -e MYSQL_DB_USER=my_db_user \
    -e MYSQL_DB_PASS=my_db_pass \
    -e MEMCACHED_ENABLED=True \
    -e MEMCACHED_MEM=128m \
    -e MYSQLDUMP_ENABLED=True \
    robostlund/nginx-php-fpm-mysql-static-data:latest

