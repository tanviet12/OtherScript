#!/bin/bash
count=`ls -l /backup | grep root | awk '{print$9}' | wc -l`
#echo $count
if [[ $count -gt 7 ]];
then
let "count_new=$count-7"
#echo $count_new
ls -l /backup | grep root | awk '{print$9}' | tail -$count_new   > /tmp/bkdel.txt
fi

while read line
do
rm -rf /backup/$line/
echo Remove $line directory completed `date` >> /var/log/backuplog
done < /tmp/bkdel.txt

rsync -r /backup/ /var/www/2mit/backup/

echo -------------------------------------------------------------- >> /var/log/backuplog
rm -rf /tmp/bkdel.txt