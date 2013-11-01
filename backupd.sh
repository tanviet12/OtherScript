#!/bin/bash

# Script backup
# Author: Tan Viet - VinaHost

USER="root"
PASSWD="bbc@381"
DES_DIR="/backup/data"
SOURCE_DIR="/home/"
TODAY="$(date +"%Y-%m-%d")"
YESTERDAY=`date -d '1 day ago' +'%Y-%m-%d'`
KEEP_BK=3

#Backup all database MySQL

mkdir -p $DES_DIR/$TODAY/database

dblist=`mysqlshow -u$USER -p$PASSWD | sed 's/|//g' | sed '1,4d' | sed '/+------/ d' | sed 's/ //g'`

array_db=( $dblist )

echo "" >> /var/log/backupd.log

echo ==============BEGIN BACKUP DATABASE `date` ================== >> /var/log/backupd.log

for((i=0;i<${#array_db[@]};i++))

do
        dbname=${array_db[$i]}
                [ `cat /proc/loadavg |awk -F. {'print $1'}` -gt 16 ] && sleep 300 && echo "Hight load... sleep 300s " >> /var/log/backupd.log
        mysqldump --single-transaction -u$USER -p$PASSWD --complete-insert $dbname  | gzip -9 > $DES_DIR/$TODAY/database/$dbname.`date +"%Y-%m-%d"`.sql.gz && echo Success backup database $dbname on `date` >> /var/log/backupd.log || echo Failse backup database $dbname on `date` >> /var/log/backupd.log

done

echo ==============END BACKUP DATABASE `date` ==================== >> /var/log/backupd.log

# Backup source website

echo "" >> /var/log/backupd.log
echo ==============BEGIN BACKUP SOURCE WEBSITE `date` ================== >> /var/log/backupd.log
mkdir -p $DES_DIR/$TODAY/source

if [ -d $DES_DIR/$YESTERDAY/source ] ; then

   rsync -ar $DES_DIR/$YESTERDAY/source/ $DES_DIR/$TODAY/source/ && echo rsync source yesterday complete >> /var/log/backupd.log || echo Failed rsync source yesterday >> /var/log/backupd.log

fi

rsync -ar $SOURCE_DIR $DES_DIR/$TODAY/source/ && echo Backup $SOURCE complete `date` >> /var/log/backupd.log || echo Failed to backup $SOURCE directory on `date` >> /var/log/backupd.log

echo ==============END BACKUP `date` ==================== >> /var/log/backupd.log


# Remove backup

list_bk_folder=`ls -l $DES_DIR | grep root | grep -v ./ | awk '{print$9}'`
array_bk_folder=( $list_bk_folder );


for (( i=0;i< ${#array_bk_folder[@]}; i++ ))

do
        stat11=`stat -c %Y $DES_DIR/${array_bk_folder[$i]}`
        array_bk_stat[$i]=$stat11
done
for ((i=0;i< ${#array_bk_stat[@]};i++))
do
        stat1=${array_bk_stat[$i]}
        for (( j=1; j < ${#array_bk_stat[@]}; j++ ))
        do
                stat2=${array_bk_stat[$j]}
                if [ $((stat1)) -lt $((stat2)) ];
                then
                         tempstring=$stat1
                         stat1=$stat2
                         stat2=$tempstring
                         array_bk_stat[$i]=$stat1
                         array_bk_stat[$j]=$stat2
                fi
        done

done

let "DELETE_BK=${#array_bk_stat[@]}-$KEEP_BK"

for ((i=0;i<$DELETE_BK;i++))

do
        for ((j=0;j<${#array_bk_stat[@]};j++))

        do
                stat1=`stat -c %Y $DES_DIR/${array_bk_folder[$i]}`
                stat2=${array_bk_stat[$j]}

                if [ $((stat2)) -eq $((stat1)) ];
                then
                        cd $DES_DIR
                        rm -rf ${array_bk_folder[$i]} && echo Remove ${array_bk_folder[$i]} backup directory completed `date` >> /var/log/backupd.log|| echo Failed to remove ${array_bk_folder[$i]} backup directory on `date` >> /var/log/backupd.log
                        break
                fi
        done
done
