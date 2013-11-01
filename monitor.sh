#!/bin/bash

#script monitor 
export _loadavg=$( cat /proc/loadavg | awk '{ print $1, $2, $3 }')
echo "Load Average: $_loadavg on `date` " >> /var/log/monitor.log

cached=`/usr/bin/free -t -m | grep "Mem" | awk '{print$7}'`
free=`/usr/bin/free -t -m | grep "Mem" | awk '{print$4}'`
echo "Memory: Free $free - Cached $cached " >> /var/log/monitor.log
echo "============================================================="