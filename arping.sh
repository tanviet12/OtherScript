
#!/bin/bash
#VietBT

IPLIST="/root/freeip_215.txt"
for i in `cat $IPLIST`; do

        PCOUNT=`/bin/ping $i -w 2 | grep icmp | wc -l`
        if [ $PCOUNT -gt 0 ];
        then
                MAC=`/usr/sbin/arping $i -c 1 | grep from | cut -d" " -f4`
                echo $i $MAC >> /root/ip.txt
                #echo $i >> /root/ip.txt
        fi

done

