#!/bin/bash
# Script backup all database MySQL
# Author: Tan Viet - VinaHost

USER="mnvn"
PASSWD="knRjMp3d"
SUBFOLDER="$(date +"%Y-%m-%d")"
DIR="/backup/$SUBFOLDER/database/"

mkdir -p $DIR

dblist=`mysqlshow -u$USER -p$PASSWD | sed 's/|//g' | sed '1,4d' | sed '/+------/ d' | sed 's/ //g'`

array_db=( $dblist )

echo "" >> /var/log/backupdb.log
echo ==============BEGIN BACKUP DATABASE `date` ================== >> /var/log/backupdb.log

for((i=0;i<${#array_db[@]};i++))
do
        dbname=${array_db[$i]}
        mysqldump --single-transaction -u$USER -p$PASSWD --complete-insert $dbname  | gzip -9 > $DIR$dbname.`date +"%Y-%m-%d"`.sql.gz && echo Success backup database $dbname on `date` >> /var/log/backupdb.log || echo Failse backup database $dbname on `date` >> /var/log/backupdb.log

done

echo ==============END BACKUP `date` ==================== >> /var/log/backupdb.log
