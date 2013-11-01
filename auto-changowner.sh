#!/bin/bash
#auto change owner for cpanel
find  /home -user apache -type d | awk -F"/" '{print$3}' | uniq > user-chown.txt
while read line
do
chown -R $line.$line /test/$line/
echo "/home/$line done"
done < user-chown.txt