#/bin/bash

DB="dbname"
ENGINE="MyISAM"
DB_LIST=`mysqlshow $DB |  sed 's/|//g' | sed '1,4d' | sed '/+------/ d' | sed 's/ //g'`
TABLES_ARRAY=( $DB_LIST )

for((i=0;i<${#TABLES_ARRAY[@]};i++))

do
        TABLE=${TABLES_ARRAY[$i]}
        mysql -e "alter table $DB.$TABLE engine=$ENGINE" >> /var/log/output.alter.log && echo "Suscess alter table $DB.$TABLE" >> /var/log/alter.log || "Failed alter table $DB.$TABLE" >> /var/log/alter.log

done
