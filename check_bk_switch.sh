#!/bin/bash

HOSTNAME=`/bin/hostname`
SUBJECT="Backup Switch error on $HOSTNAME"
ATTACH="/tmp/mailattach.txt"
BK_DIR="/var/lib/tftpboot/"
COUNT_BK_ERROR=`find $BK_DIR -iname "*.conf" -mtime +1 | wc -l`

if [ $COUNT_BK_ERROR -gt 0 ]; then

        echo Backup switch error on $HOSTNAME. Please check timestamp of backup file. List of backup errors below: > /tmp/msg.txt
        find $BK_DIR -iname "*.conf" -mtime +1  | cut -d"/" -f5 | cut -d"." -f1 >> /tmp/msg.txt
        ls -al $BK_DIR > $ATTACH
        mutt -s "$SUBJECT" support.team@vinahost.vn -a $ATTACH < /tmp/msg.txt

fi
