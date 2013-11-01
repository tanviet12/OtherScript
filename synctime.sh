#!/bin/bash
#script cap nhat gio cho he thong
#vi chua ccnfig firewall allow port ntpd
# nen khi gio sai, tam thoi chay script nay
service iptables stop
ntpdate pool.ntp.org
service iptables start
./iptable.sh
echo "Done..."
