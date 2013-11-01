#!/bin/bash
user_name=$1
directory=$2
mkdir -p $directory
useradd -d $directory -s /sbin/nologin $user_name
printf "\nPlease input password for user %s\n" "$user_name"
passwd $user_name
chmod 755 -R $directory
chown $user_name -R $directory
service vsftpd restart
printf "\n============================\n Add user successfull with user name%s and home directory  %s\n" "$user_name $directory"
echo "============================="