#!/bin/bash
USER=${MYSQL_USERNAME:-admin}
BACKUPUSER=${MYSQL_BACKUPUSER:-backup}
PASS=${MYSQL_PASSWORD:-$(pwgen -s -1 16)}
BACKUPPASS=${MYSQL_BACKUPPASSWORD:-backupUserPassword}
DB=${MYSQL_DBNAME:-users}

# Start MySQL service
/usr/bin/mysqld_safe &
while ! nc -vz localhost 3306; do sleep 1; done

# Create users
echo "Creating user: \"$USER\"..."
/usr/bin/mysql -uroot -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$PASS'"
/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION"
echo "Creating backup user:  \"$BACKUPUSER\"..."
/usr/bin/mysql -uroot -e "CREATE USER '$BACKUPUSER'@'%' IDENTIFIED BY '$BACKUPPASS'" 
/usr/bin/mysql -uroot -e "GRANT SELECT, LOCK TABLES ON *.* TO '$BACKUPUSER'@'%' IDENTIFIED BY '$BACKUPPASS'"

# Create dabatase
if [ ! -z "$DB" ]; then
    echo "Creating database: \"$DB\"..."
    /usr/bin/mysql -uroot -e "CREATE DATABASE $DB"
fi

# Stop MySQL service
mysqladmin -uroot shutdown
while nc -vz localhost 3306; do sleep 1; done

echo "========================================================================"
echo "MySQL User: \"$USER\""
echo "MySQL Password: \"$PASS\""
if [ ! -z $DB ]; then
    echo "MySQL Database: \"$DB\""
fi
echo "========================================================================"

rm -f /.firstrun
