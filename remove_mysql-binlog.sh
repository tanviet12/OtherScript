#!/bin/bash
# 
# VietBT
# Script remove MySQL bin-log

USER=""
PASS=""
KEEP_HOUR=3

TIME=`/bin/date +"%Y-%m-%d %H:%M:%S"  --date="$KEEP_HOUR hours ago"`

/usr/bin/mysql -u$USER -p$PASS -e "PURGE BINARY LOGS BEFORE '$TIME';"
