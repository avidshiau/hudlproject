#!/bin/bash
TIMESTAMP=$(date --utc +%y%m%d%H%M%S)

# Lock the master database
/usr/bin/mysql -uroot -e "USE users; FLUSH TABLES WITH READ LOCK;"
if ["$?" -ne 0]; then echo "command failed"; exit 1; fi

# Dump the current database
/usr/bin/mysqldump -uroot -p --host=127.0.0.1 --port=3306 --all-databases --master-data=2 > /mysqldumps/$TIMESTAMP.sql
if ["$?" -ne 0]; then echo "command failed"; exit 1; fi

# Unlock the master database
/usr/bin/mysql -uroot -e "USE users; UNLOCK TABLES;"
if ["$?" -ne 0]; then echo "command failed"; exit 1; fi
