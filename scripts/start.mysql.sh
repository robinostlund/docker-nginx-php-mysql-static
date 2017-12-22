#!/bin/bash

. /usr/local/bin/sources.sh

set -x

# create folders and set correct permissions
if [ ! -d /run/mysqld ]; then
  mkdir -p /run/mysqld
  chmod -R 0755 /run/mysqld
  chown -R mysql:root /run/mysqld
fi

if [ ! -d /data/var/log/mysql ]; then
  mkdir -p /data/var/log/mysql
  chmod -R 0755 /data/var/log/mysql
  chown -R mysql:mysql /data/var/log/mysql
fi

# initialize mysql database
if [ ! -d /data/var/lib/mysql ]; then
  # create folders as we don't have any today
  mkdir -p /data/var/lib/mysql
  chmod -R 0700 /data/var/lib/mysql
  chown -R mysql:mysql /data/var/lib/mysql

  # initialize database
  mysqld --initialize-insecure --user mysql >/dev/null 2>&1

  # start mysql server
  /usr/bin/mysqld_safe >/dev/null 2>&1 &

  # wait for mysql server to start (max 30 seconds)
  timeout=30
  echo -n "Waiting for database server to accept connections"
  while ! /usr/bin/mysqladmin status >/dev/null 2>&1
  do
    timeout=$(($timeout - 1))
    if [ $timeout -eq 0 ]; then
      echo -e "\nCould not connect to database server. Aborting..."
      exit 1
    fi
    echo -n "."
    sleep 1
  done
  # creating debian-sys-maint user without password
  mysql -e "CREATE USER 'debian-sys-maint'@'localhost' IDENTIFIED BY '';"
  mysql -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"

  /usr/bin/mysqladmin shutdown
fi

# set correct permissions if they have been changed
chown -R mysql:mysql /data/var/lib/mysql
chown -R mysql:root /run/mysqld

# create new user / database
if [ ! -z $MYSQL_DB_USER ]; then
  if [ ! -z $MYSQL_DB_NAME ]; then
    /usr/bin/mysqld_safe >/dev/null 2>&1 &

    # wait for mysql server to start (max 30 seconds)
    timeout=30
    while ! /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf status >/dev/null 2>&1
    do
      timeout=$(($timeout - 1))
      if [ $timeout -eq 0 ]; then
        exit 1
      fi
      sleep 1
    done

    for db in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${MYSQL_DB_NAME}"); do
      mysql --defaults-file=/etc/mysql/debian.cnf -e "CREATE DATABASE IF NOT EXISTS \`$db\` DEFAULT CHARACTER SET \`$MYSQL_CHARSET\` COLLATE \`$MYSQL_COLLATION\`;"
        if [ ! -z "$MYSQL_DB_USER" ]; then
          mysql --defaults-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES ON \`$db\`.* TO '$MYSQL_DB_USER' IDENTIFIED BY '$MYSQL_DB_PASS';"
        fi
      done

    /usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf shutdown
  fi
fi

# enable mysqldump cronjob if specified
if [ ! -z $MYSQLDUMP_ENABLED ]; then
  echo "1 23 * * * root /usr/local/bin/run.mysqldump.sh" > /etc/cron.d/mysqldump
fi

/usr/bin/mysqld_safe
