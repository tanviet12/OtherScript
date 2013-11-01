#!/bin/bash
while read line
do
mysqldump -uroot -pVyjbFDUlM10S $line > /backup/$line.sql
echo Backup database $line completed `date` >> /var/log/backuplog
done < /root/dblist