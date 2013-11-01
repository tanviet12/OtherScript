#!/bin/bash

# Script backup vps use vzdump
DUMP_DIR="/vz/dump_manage.123host.vn/"
VMID="777"
[ `cat /proc/loadavg |awk -F. {'print $1'}` -gt 16 ] && sleep 300 && echo "Hight load... sleep 300s " >> /var/log/vzdump-manage.123host.vn.log

# Remove old dump backup
rm -rf /vz/dump_manage.123host.vn/* 

vzdump --compress --dumpdir $DUMP_DIR --exclude-path "/home/solusvm/xen/iso/" --stopwait 30 --suspend  $VMID  && echo Dump VM $VMID successfully on `date` >> /var/log/vzdump-manage.123host.vn.log || echo Dump VM $VMID failed on `date` >> /var/log/vzdump-manage.123host.vn.log
