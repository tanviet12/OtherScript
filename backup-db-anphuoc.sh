#!/bin/bash
#
# Username to access the MySQL
USERNAME=ten_user_database

# Username to access the MySQL
PASSWORD=matkhau

# Host name (or IP address) of MySQL
DBHOST=localhost

# danh sach database can backup "DB1 DB2 DB3"
DBNAMES="ten_database"

# thu muc chua file backup
BACKUPDIR="/anphuoc/backup"

# sau khi backup se goi mail bao cho admin bik
MAILCONTENT="Da backup database"

# dung luong toi da cua email (4000 = approx 5MB email)
MAXATTSIZE="4000"

# Email cua admin la gi?
MAILADDR="anphuoc@hoithanh.com"


# ============================================================

# list database
MDBNAMES="mysql $DBNAMES"

# List of DBNAMES to EXLUCDE if DBNAMES are set to all
DBEXCLUDE=""

# tao database backup
CREATE_DATABASE=yes

# moi database la mot thuc muc luu rieng hay chung
SEPDIR=yes

# can luu giu may ban backup trong tuan?
DOWEEKLY=6

# dinh dang nen la gi?
COMP=gzip

# Compress communications between backup server and MySQL server?
COMMCOMP=no

# co luu giu ban backup gan day trong thang ko?
LATEST=no

#  The maximum size of the buffer for client/server communication. e.g. 16MB
MAX_ALLOWED_PACKET=

#  For connections to localhost. Sometimes the Unix socket file must be specified.
SOCKET=

PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/mysql/bin
DATE=`date +%Y-%m-%d_%Hh%Mm`                # Datestamp e.g 2002-09-21
DOW=`date +%A`                            # Day of the week e.g. Monday
DNOW=`date +%u`                        # Day number of the week 1 to 7 where 1 represents Monday
DOM=`date +%d`                            # Date of the Month e.g. 27
M=`date +%B`                            # Month e.g January
W=`date +%V`                            # Week Number e.g 37
VER=2.5                                    # Version Number
LOGFILE=$BACKUPDIR/$DBHOST-`date +%N`.log        # Logfile Name
LOGERR=$BACKUPDIR/ERRORS_$DBHOST-`date +%N`.log        # Logfile Name
BACKUPFILES=""
OPT="--quote-names --opt"            # OPT string for use with mysqldump ( see man mysqldump )

# Add --compress mysqldump option to $OPT
if [ "$COMMCOMP" = "yes" ];
    then
        OPT="$OPT --compress"
    fi

# Add --compress mysqldump option to $OPT
if [ "$MAX_ALLOWED_PACKET" ];
    then
        OPT="$OPT --max_allowed_packet=$MAX_ALLOWED_PACKET"
    fi

# Create required directories
if [ ! -e "$BACKUPDIR" ]        # Check Backup Directory exists.
    then
    mkdir -p "$BACKUPDIR"
fi

if [ ! -e "$BACKUPDIR/daily" ]        # Check Daily Directory exists.
    then
    mkdir -p "$BACKUPDIR/daily"
fi

if [ ! -e "$BACKUPDIR/weekly" ]        # Check Weekly Directory exists.
    then
    mkdir -p "$BACKUPDIR/weekly"
fi

if [ ! -e "$BACKUPDIR/monthly" ]    # Check Monthly Directory exists.
    then
    mkdir -p "$BACKUPDIR/monthly"
fi

if [ "$LATEST" = "yes" ]
then
    if [ ! -e "$BACKUPDIR/latest" ]    # Check Latest Directory exists.
    then
        mkdir -p "$BACKUPDIR/latest"
    fi
eval rm -fv "$BACKUPDIR/latest/*"
fi

# IO redirection for logging.
touch $LOGFILE
exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
exec > $LOGFILE     # stdout replaced with file $LOGFILE.
touch $LOGERR
exec 7>&2           # Link file descriptor #7 with stderr.
                    # Saves stderr.
exec 2> $LOGERR     # stderr replaced with file $LOGERR.


# Functions

# Database dump function
dbdump () {
mysqldump --user=$USERNAME --password=$PASSWORD --host=$DBHOST $OPT $1 > $2
return 0
}

# Compression function plus latest copy
SUFFIX=""
compression () {
if [ "$COMP" = "gzip" ]; then
    gzip -f "$1"
    echo
    echo Backup Information for "$1"
    gzip -l "$1.gz"
    SUFFIX=".gz"
elif [ "$COMP" = "bzip2" ]; then
    echo Compression information for "$1.bz2"
    bzip2 -f -v $1 2>&1
    SUFFIX=".bz2"
else
    echo "No compression option set, check advanced settings"
fi
if [ "$LATEST" = "yes" ]; then
    cp $1$SUFFIX "$BACKUPDIR/latest/"
fi    
return 0
}


# Run command before we begin
if [ "$PREBACKUP" ]
    then
    echo ======================================================================
    echo "Prebackup command output."
    echo
    eval $PREBACKUP
    echo
    echo ======================================================================
    echo
fi


if [ "$SEPDIR" = "yes" ]; then # Check if CREATE DATABSE should be included in Dump
    if [ "$CREATE_DATABASE" = "no" ]; then
        OPT="$OPT --no-create-db"
    else
        OPT="$OPT --databases"
    fi
else
    OPT="$OPT --databases"
fi

# Hostname for LOG information
if [ "$DBHOST" = "localhost" ]; then
    HOST=`hostname`
    if [ "$SOCKET" ]; then
        OPT="$OPT --socket=$SOCKET"
    fi
else
    HOST=$DBHOST
fi

# If backing up all DBs on the server
if [ "$DBNAMES" = "all" ]; then
        DBNAMES="`mysql --user=$USERNAME --password=$PASSWORD --host=$DBHOST --batch --skip-column-names -e "show databases"| sed 's/ /%/g'`"

    # If DBs are excluded
    for exclude in $DBEXCLUDE
    do
        DBNAMES=`echo $DBNAMES | sed "s/\b$exclude\b//g"`
    done

        MDBNAMES=$DBNAMES
fi
    
echo ======================================================================
echo AutoMySQLBackup VER $VER
echo http://sourceforge.net/projects/automysqlbackup/
echo
echo Backup of Database Server - $HOST
echo ======================================================================

# Test is seperate DB backups are required
if [ "$SEPDIR" = "yes" ]; then
echo Backup Start Time `date`
echo ======================================================================
    # Monthly Full Backup of all Databases
    if [ $DOM = "01" ]; then
        for MDB in $MDBNAMES
        do

             # Prepare $DB for using
                MDB="`echo $MDB | sed 's/%/ /g'`"

            if [ ! -e "$BACKUPDIR/monthly/$MDB" ]        # Check Monthly DB Directory exists.
            then
                mkdir -p "$BACKUPDIR/monthly/$MDB"
            fi
            echo Monthly Backup of $MDB...
                dbdump "$MDB" "$BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.sql"
                compression "$BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.sql"
                BACKUPFILES="$BACKUPFILES $BACKUPDIR/monthly/$MDB/${MDB}_$DATE.$M.$MDB.sql$SUFFIX"
            echo ----------------------------------------------------------------------
        done
    fi

    for DB in $DBNAMES
    do
    # Prepare $DB for using
    DB="`echo $DB | sed 's/%/ /g'`"
    
    # Create Seperate directory for each DB
    if [ ! -e "$BACKUPDIR/daily/$DB" ]        # Check Daily DB Directory exists.
        then
        mkdir -p "$BACKUPDIR/daily/$DB"
    fi
    
    if [ ! -e "$BACKUPDIR/weekly/$DB" ]        # Check Weekly DB Directory exists.
        then
        mkdir -p "$BACKUPDIR/weekly/$DB"
    fi
    
    # Weekly Backup
    if [ $DNOW = $DOWEEKLY ]; then
        echo Weekly Backup of Database \( $DB \)
        echo Rotating 5 weeks Backups...
            if [ "$W" -le 05 ];then
                REMW=`expr 48 + $W`
            elif [ "$W" -lt 15 ];then
                REMW=0`expr $W - 5`
            else
                REMW=`expr $W - 5`
            fi
        eval rm -fv "$BACKUPDIR/weekly/$DB_week.$REMW.*"
        echo
            dbdump "$DB" "$BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.sql"
            compression "$BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.sql"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/weekly/$DB/${DB}_week.$W.$DATE.sql$SUFFIX"
        echo ----------------------------------------------------------------------
    
    # Daily Backup
    else
        echo Daily Backup of Database \( $DB \)
        echo Rotating last weeks Backup...
        eval rm -fv "$BACKUPDIR/daily/$DB/*.$DOW.sql.*"
        echo
            dbdump "$DB" "$BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.sql"
            compression "$BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.sql"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/daily/$DB/${DB}_$DATE.$DOW.sql$SUFFIX"
        echo ----------------------------------------------------------------------
    fi
    done
echo Backup End `date`
echo ======================================================================


else # One backup file for all DBs
echo Backup Start `date`
echo ======================================================================
    # Monthly Full Backup of all Databases
    if [ $DOM = "01" ]; then
        echo Monthly full Backup of \( $MDBNAMES \)...
            dbdump "$MDBNAMES" "$BACKUPDIR/monthly/$DATE.$M.all-databases.sql"
            compression "$BACKUPDIR/monthly/$DATE.$M.all-databases.sql"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/monthly/$DATE.$M.all-databases.sql$SUFFIX"
        echo ----------------------------------------------------------------------
    fi

    # Weekly Backup
    if [ $DNOW = $DOWEEKLY ]; then
        echo Weekly Backup of Databases \( $DBNAMES \)
        echo
        echo Rotating 5 weeks Backups...
            if [ "$W" -le 05 ];then
                REMW=`expr 48 + $W`
            elif [ "$W" -lt 15 ];then
                REMW=0`expr $W - 5`
            else
                REMW=`expr $W - 5`
            fi
        eval rm -fv "$BACKUPDIR/weekly/week.$REMW.*"
        echo
            dbdump "$DBNAMES" "$BACKUPDIR/weekly/week.$W.$DATE.sql"
            compression "$BACKUPDIR/weekly/week.$W.$DATE.sql"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/weekly/week.$W.$DATE.sql$SUFFIX"
        echo ----------------------------------------------------------------------
        
    # Daily Backup
    else
        echo Daily Backup of Databases \( $DBNAMES \)
        echo
        echo Rotating last weeks Backup...
        eval rm -fv "$BACKUPDIR/daily/*.$DOW.sql.*"
        echo
            dbdump "$DBNAMES" "$BACKUPDIR/daily/$DATE.$DOW.sql"
            compression "$BACKUPDIR/daily/$DATE.$DOW.sql"
            BACKUPFILES="$BACKUPFILES $BACKUPDIR/daily/$DATE.$DOW.sql$SUFFIX"
        echo ----------------------------------------------------------------------
    fi
echo Backup End Time `date`
echo ======================================================================
fi
echo Total disk space used for backup storage..
echo Size - Location
echo `du -hs "$BACKUPDIR"`
echo
echo ======================================================================
echo If you find AutoMySQLBackup valuable please make a donation at
echo http://sourceforge.net/project/project_donations.php?group_id=101066
echo ======================================================================

# Run command when we're done
if [ "$POSTBACKUP" ]
    then
    echo ======================================================================
    echo "Postbackup command output."
    echo
    eval $POSTBACKUP
    echo
    echo ======================================================================
fi

#Clean up IO redirection
exec 1>&6 6>&-      # Restore stdout and close file descriptor #6.
exec 1>&7 7>&-      # Restore stdout and close file descriptor #7.

if [ "$MAILCONTENT" = "files" ]
then
    if [ -s "$LOGERR" ]
    then
        # Include error log if is larger than zero.
        BACKUPFILES="$BACKUPFILES $LOGERR"
        ERRORNOTE="WARNING: Error Reported - "
    fi
    #Get backup size
    ATTSIZE=`du -c $BACKUPFILES | grep "[[:digit:][:space:]]total$" |sed s/\s*total//`
    if [ $MAXATTSIZE -ge $ATTSIZE ]
    then
        BACKUPFILES=`echo "$BACKUPFILES" | sed -e "s# # -a #g"`    #enable multiple attachments
        mutt -s "$ERRORNOTE MySQL Backup Log and SQL Files for $HOST - $DATE" $BACKUPFILES $MAILADDR < $LOGFILE        #send via mutt
    else
        cat "$LOGFILE" | mail -s "WARNING! - MySQL Backup exceeds set maximum attachment size on $HOST - $DATE" $MAILADDR
    fi
elif [ "$MAILCONTENT" = "log" ]
then
    cat "$LOGFILE" | mail -s "MySQL Backup Log for $HOST - $DATE" $MAILADDR
    if [ -s "$LOGERR" ]
        then
            cat "$LOGERR" | mail -s "ERRORS REPORTED: MySQL Backup error Log for $HOST - $DATE" $MAILADDR
    fi    
elif [ "$MAILCONTENT" = "quiet" ]
then
    if [ -s "$LOGERR" ]
        then
            cat "$LOGERR" | mail -s "ERRORS REPORTED: MySQL Backup error Log for $HOST - $DATE" $MAILADDR
            cat "$LOGFILE" | mail -s "MySQL Backup Log for $HOST - $DATE" $MAILADDR
    fi
else
    if [ -s "$LOGERR" ]
        then
            cat "$LOGFILE"
            echo
            echo "###### WARNING ######"
            echo "Errors reported during AutoMySQLBackup execution.. Backup failed"
            echo "Error log below.."
            cat "$LOGERR"
    else
        cat "$LOGFILE"
    fi    
fi

if [ -s "$LOGERR" ]
    then
        STATUS=1
    else
        STATUS=0
fi

# Clean up Logfile
eval rm -f "$LOGFILE"
eval rm -f "$LOGERR"

exit $STATUS