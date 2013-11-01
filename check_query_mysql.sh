#!/bin/bash
# Script check mysql service
# Author: Tan Viet - VinaHost

COUNT_QUERY=`/usr/bin/mysqladmin proc | wc -l`
HOSTNAME=`/bin/hostname`
echo "Too many query MySQL on $HOSTNAME . Please check MySQL service" > /tmp/msg.txt
SUBJECT="Too many query MySQL on $HOSTNAME"
ATTACH="/tmp/mailattach.txt"
if [ $COUNT_QUERY -gt 70 ]; then

        /usr/bin/mysqladmin proc >> $ATTACH
        mutt -s "$SUBJECT" -a $ATTACH support.team@vinahost.vn < /tmp/msg.txt
        rm -rf $ATTACH

fi
