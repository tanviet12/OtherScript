#!/bin/bash
# Script backup all database MySQL
# Author: Tan Viet - VinaHost

DIR="/data/backup/"
KEEP_BK=5
list_bk_folder=`ls -l $DIR | grep root | awk '{print$9}'`
array_bk_folder=( $list_bk_folder );


for (( i=0;i< ${#array_bk_folder[@]}; i++ ))

do
        stat11=`stat -c %Y $DIR${array_bk_folder[$i]}`
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
                stat1=`stat -c %Y $DIR${array_bk_folder[$i]}`
                stat2=${array_bk_stat[$j]}

                if [ $((stat2)) -eq $((stat1)) ];
                then
                        cd $DIR
                        rm -rf ${array_bk_folder[$i]} && echo Remove ${array_bk_folder[$i]} backup directory completed `date` >> /var/log/remove_backup.log || echo Failed to remove ${array_bk_folder[$i]} backup directory on `date` >> /var/log/remove_backup.log 
                        break
                fi
        done
done