#!/bin/bash
# Script backup
# Author: Tan Viet - VinaHost

SOURCE="/var/www/html/betgame/"
SUBFOLDER="$(date +"%Y-%m-%d")"
DEST="/data"
DIR="$DEST/backup/$SUBFOLDER/source/"

mkdir -p $DIR

echo "" >> /var/log/backup_source.log
echo ==============BEGIN BACKUP SOURCE WEBSITE `date` ================== >> /var/log/backup_source.log

rsync -ar $SOURCE $DIR && echo Backup $SOURCE complete `date` >> /var/log/backup_source.log || echo Failed to backup $SOURCE directory on `date` >> /var/log/backup_source.log

echo ==============END BACKUP `date` ==================== >> /var/log/backup_source.log