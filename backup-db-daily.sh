#!/bin/bash
#echo ------------------------------------------------------------ >> /backup/backuplog
echo Backup database 2mit Started `date` >> /backup/backuplog
mkdir -p /backup/`date +%d%m%Y`
mysqldump -uroot -paA1234567890 2mit_forum > /backup/`date +%d%m%Y`/2mitorg-db.sql
tar cpzf /backup/`date +%d%m%Y`/2mitorg-db.sql.tar.gz /backup/`date +%d%m%Y`/2mitorg-db.sql
rm -rf /backup/`date +%d%m%Y`/2mitorg-db.sql
echo Backup database 2mit Completed `date` >> /backup/backuplog
echo -------------------------------------------------------------- >> /backup/backuplog
