#!/bin/bash

# Script backup source website

# Author: Tan Viet - VinaHost

SOURCE="/home/mit/public_html/"
SUBFOLDER="$(date +"%Y-%m-%d")"
DIR="/backup/$SUBFOLDER/source/"
YESTERDAY=`date -d '1 day ago' +'%Y-%m-%d'`

echo "" >> /var/log/backup_source.log
echo ==============BEGIN BACKUP SOURCE WEBSITE `date` ================== >> /var/log/backup_source.log

if [ -d /backup/$YESTERDAY/source ] ; then

   rsync -ar /backup/$YESTERDAY/source/ $DIR && echo rsync source yesterday complete >> /var/log/backup_source.log || echo Failed rsync source yesterday >> /var/log/backup_source.log

fi

mkdir -p $DIR

rsync -ar $SOURCE $DIR && echo Backup $SOURCE complete `date` >> /var/log/backup_source.log || echo Failed to backup $SOURCE directory on `date` >> /var/log/backup_source.log

echo ==============END BACKUP `date` ==================== >> /var/log/backup_source.log
