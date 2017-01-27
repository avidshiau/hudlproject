#!/bin/bash
USER=${MYSQL_USERNAME:-admin}
SLAVE_USER=${MYSQL_SLAVEUSERNAME:-slaveuser}
PASS=${MYSQL_PASSWORD:-$(pwgen -s -1 16)}
DB=${MYSQL_DBNAME:-users}
TIMESTAMP=${TIMESTAMP:-$(date --utc +%y%m%d%H%M%S)}

# Start MySQL service
/usr/bin/mysqld_safe &
while ! nc -vz localhost 3306; do sleep 1; done

# Create user
echo "Creating user: \"$USER\"..."
/usr/bin/mysql -uroot -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$PASS'"
/usr/bin/mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION"

# Create slave user
echo "Creating slave user: \"$SLAVE_USER\"..."
/usr/bin/mysql -uroot -e "CREATE USER '$SLAVE_USER'@'%' IDENTIFIED BY 'aStrongSlavePassword'"
/usr/bin/mysql -uroot -e "GRANT REPLICATION SLAVE ON *.* TO '$SLAVE_USER'@'%'"

# Create dabatase
if [ ! -z "$DB" ]; then
    echo "Creating database: \"$DB\"..."
    /usr/bin/mysql -uroot -e "CREATE DATABASE $DB"
    /usr/bin/mysql -uroot -e "USE $DB; CREATE TABLE logins ( Id int NOT NULL, LoginEmail varchar(320), Password char(128), PRIMARY KEY (Id))"
    /usr/bin/mysql -uroot -e "USE $DB; INSERT INTO logins VALUES (0, 'aUser@bDomain.com', encrypt('someHardPassword', CONCAT('$5$', MD5(RAND()))))"
fi

# Dump the initial master database
/usr/bin/mysql -uroot -e "USE users; FLUSH TABLES WITH READ LOCK"
/usr/bin/mysqldump -uroot -p --host=127.0.0.1 --port=3306 --all-databases --master-data=2 > /mysqldumps/$TIMESTAMP.sql
/usr/bin/mysql -uroot -e "USE users; UNLOCK TABLES;"

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
