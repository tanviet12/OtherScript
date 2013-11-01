#!/bin/bash

mysqlshow -uroot -p121212 | sed 's/|//g' | sed '1,3d' | sed '/+------/ d' | sed 's/ //g' > /root/dblist.txt

while read line
do

mysqldump -uroot -p121212 $line > /home/backupsqldb/$line.sql
echo Finish backup database $line on `date` >> /home/backupsqldb/backup.log

done < /root/dblist.txt
