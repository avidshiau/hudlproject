#!/bin/bash
TIMESTAMP=$(date --utc +%y%m%d%H%M%S)

# Stop the slave database
service mysql stop

# Dump the current user database
/usr/bin/mysqldump -u backup --password=backupUserPassword users >/mysqlbackups/$TIMESTAMP.sql

# Restart the slave databse
service mysql start

# Update the latest folder
LATEST=$(ls -Art /mysqlbackups | tail -n 1)
if [ -d /mysqlbackups/latest ]; then 
    rm -rf /mysqlbackups/latest 
fi
mkdir /mysqlbackups/latest
cp /mysqlbackups/$LATEST /mysqlbackups/latest
