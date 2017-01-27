#!/bin/bash
HUDLPROJECTROOT=/home/ec2-user/hudlproject
if [ ! "$HUDLPROJECTROOT" ]; then 
    echo "Need to set HUDLPROJECTROOT, see initial setup instructions"
    exit 1
fi

SLAVESHA=$(docker ps | grep dbprod_slave | cut -d ' ' -f1)

if [ -d "$HUDLPROJECTROOT/dbtest/databases/latest" ]; then
    rm -R $HUDLPROJECTROOT/dbtest/databases/latest
fi
docker cp "$SLAVESHA:/mysqlbackups/latest" "$HUDLPROJECTROOT/dbtest/databases"
sudo chmod -R 777 "$HUDLPROJECTROOT/dbtest/databases/latest"
docker build --rm -t avidshiau/hudlproject/dbtest "$HUDLPROJECTROOT:dbtest"

