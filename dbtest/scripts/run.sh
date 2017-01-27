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
/usr/sbin/mysqld

# Import database
#DATABASEFILE=$(ls -Art /databases/latest | tail -n 1)
#mysql -uroot users < /databases/latest/$DATABASEFILE
