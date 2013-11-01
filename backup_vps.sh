#!/bin/bash

# Script backup VPS manage.123host.vn use vzdump

DES_HOST="192.168.1.2"
VMID="777"
DES_DIR=/vz/dump
LOCAL_DIR=/vz/backup_manage.123host.vn
TODAY="$(date +"%Y_%m_%d")"

echo " " >> /var/log/backupd.log
echo Begin backup manage.123host.vn on `date` >> /var/log/backupd.log

# Copy script backup to target server
scp /root/123host/backup_agents/vzdump_manage-123host.sh $DES_HOST:/root/123host/ && echo Copy script backup to target server successfully >> /var/log/backupd.log || echo Copy script backup to target server failed >> /var/log/backupd.log

# Execute script backup on target server
ssh $DES_HOST /root/123host/vzdump_manage-123host.sh && echo Execute script backup on target server successfully >> /var/log/backupd.log || echo Execute script backup on target server failed >> /var/log/backupd.log

# Copy data from target server to backup server
scp $DES_HOST:$DES_DIR/vzdump-openvz-$VMID-$TODAY-*.tar $LOCAL_DIR/ && echo Copy data from target server to backup server successfully >> /var/log/backupd.log || echo Copy data from target server to backup server failed >> /var/log/backupd.log

echo End backup manage.123host.vn on `date` >> /var/log/backupd.log
echo " " >> /var/log/backupd.log
