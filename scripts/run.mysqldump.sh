#!/bin/bash
MYSQLDUMP_CURDATE=`date "+%Y%m%d_%H%M%S"`
MYSQL_DBS=`mysql --defaults-file=/etc/mysql/debian.cnf -NBe "show databases"|grep -v -E "information_schema|performance_schema"`

if [ ! -d /data/var/backups/mysql ]; then
  mkdir -p /data/var/backups/mysql
fi

mysqldump_start()  {
  for database in $MYSQL_DBS; do
    mysqldump --defaults-file=/etc/mysql/debian.cnf --single-transaction --routines --triggers --events "$database" | gzip -9 > "/data/var/backups/mysql/$MYSQLDUMP_CURDATE.$database.gz";
  done
}

mysqldump_clear() {
  find /data/var/backups/mysql -type f -mtime +7 -exec rm {} \;
}

mysqldump_start
mysqldump_clear
