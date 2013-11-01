#!/bin/bash
#echo ------------------------------------------------------------ >> /backup/backuplog
echo Backup 2mit Started `date` >> /backup/backuplog
mkdir -p /backup/`date +%d%m%Y`
tar cpzf /backup/`date +%d%m%Y`/2mitorg.tar.gz /var/www/2mit
echo Backup 2mit Completed `date` >> /backup/backuplog
echo -------------------------------------------------------------- >> /backup/backuplog
