#!/bin/sh
#

NOW=`date +%Y-%m-%d.%H%M%S`
IP=`echo $SSH_CLIENT | sed 's/ .*//'`
LOGFILE=/log-session/`whoami`.log
echo ======================================== >> $LOGFILE
echo Starting interactive shell session by user `whoami` - IP: $IP >> $LOGFILE
echo ======================================== >> $LOGFILE
exec script -a -f -q $LOGFILE
