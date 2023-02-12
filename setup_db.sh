#!/bin/bash
sql_slave_user='CREATE USER "replication"@"%" IDENTIFIED BY "1111"; GRANT REPLICATION SLAVE ON *.* TO "replication"@"%"; FLUSH PRIVILEGES;'
docker exec node1 sh -c "mysql -u root -pabcd -e '$sql_slave_user'"
MS_STATUS=`docker exec node1 sh -c 'mysql -u root -pabcd -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`
sql_set_master="CHANGE MASTER TO MASTER_HOST='node1',MASTER_USER='replication',MASTER_PASSWORD='1111',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='mysql -u root -pabcd -e "'
start_slave_cmd+="$sql_set_master"
start_slave_cmd+='"'
docker exec node2 sh -c "$start_slave_cmd"
docker exec node2 sh -c "mysql -u root -pabcd -e 'SHOW SLAVE STATUS \G'"