#!/bin/bash

. /lib/lsb/init-functions

/usr/sbin/cron -f -l -L 15
