Docker container with nginx, php-fpm, mysql and cron
============================================================================
----------
######  Information

Multiple processes inside the container managed by supervisord:

- nginx
- php-fpm
- mysqld
- memcached

----------
###### Environment variables:

 - PHP_MEM: Specify max memory usage for php-fpm here (default 128M)
 - MEMCACHED_MEM: Specify max memory usage for memcached here (default 64M)
 - MYSQL_DB_NAME: Specify db name here
 - MYSQL_DB_USER: Specify db user here
 - MYSQL_DB_PASS: Specify db pass here
 - MYSQL_CHARSET: Specify mysql charset here (default: utf8)
 - MYSQL_COLLATION: Specify mysql collation here (default utf8_unicode_ci)
 - MYSQLDUMP_ENABLED: Specify True if you would like to enable cronjob for mysqldump that will start at 23 every day and keep 7 days of backups (default False)
 - MEMCACHED_ENABLED: Specify True if you would like to start memcached (default False)
 - MEMCACHED_MEM: Specify memcached memory amount (default 64m)
 - NGINX_X_FORWARDED_FOR: Specify True if you would like to use X-FORWARD-FOR header (default False)


----------
###### Volume configuration:

- /data
  - /data/var/log
    - /data/log/nginx
    - /data/log/mysql
  - /data/var/lib
    - /data/var/lib/mysql
  - /data/var/www
    - /data/var/www/html
     - /data/var/www/html/config
     - /data/var/www/html/public_html
  - /data/var/backups
   - /data/var/backups/mysql

----------
###### Run example:
```sh
$ docker run -dt \
    --name httptest \
    --hostname httptest \
    -p 8080:80 \
    -v /tmp/test:/data \
    -e MYSQL_DB_NAME=testdb \
    -e MYSQL_DB_USER=test_user \
    -e MYSQL_DB_PASS=test_pass \
    -e MYSQLDUMP_ENABLED=true \
    -e NGINX_X_FORWARDED_FOR=true \
    -e MEMCACHED_ENABLED=true \
    -e MEMCACHED_MEM=128m \
    robostlund/nginx-php-mysql-static:latest
```

----------
###### Ansible example:
```sh
    - name: create container
      docker_container:
        name: 'www01'
        hostname: www01
        image: robostlund/nginx-php-mysql-static:latest
        recreate: yes
        pull: true
        ports:
          - "8080:80" # http
        volumes:
          - '/tmp/data:/data'
        env:
          MYSQL_DB_NAME: my_mysql_db
          MYSQL_USER: my_mysql_user
          MYSQL_PASSQWORD: my_mysql_password
          MYSQLDUMP_ENABLED: yes
          NGINX_X_FORWARDED_FOR: yes
          MEMCACHED_ENABLED: yes
```
