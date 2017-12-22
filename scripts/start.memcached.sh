#!/bin/bash

. /usr/local/bin/sources.sh

set -x

if [ ! -z $MEMCACHED_ENABLED ]; then
  memcached -p 11211 -m $MEMCACHED_MEM -u memcache
fi
