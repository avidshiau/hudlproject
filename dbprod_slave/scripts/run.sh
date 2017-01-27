#!/bin/bash

# Initialize data directory
DATA_DIR=/data
if [ ! -f $DATA_DIR/mysql ]; then
    mysql_install_db
fi

# Initialize first run
if [[ -e /.firstrun ]]; then
    /scripts/first_run.sh
fi

# Start MySQL
echo "Starting MySQL..."
/usr/sbin/mysqld &

# Start cron
cron && tail -f /var/log/cron.log

# Start nfs
service nfs-kernel-server restart
