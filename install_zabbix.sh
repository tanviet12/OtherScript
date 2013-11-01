#!/bin/bash

#Install zabbix agentd

ARC=`uname -a | awk '{print $12}'`
if [ $ARC == 'x86_64' ]; then
	ARC="amd64"
else
	ARC="i386"
fi

cd /usr/local/src/

wget http://www.zabbix.com/downloads/2.0.6/zabbix_agents_2.0.6.linux2_6.$ARC.tar.gz


tar xf zabbix_agents_2.0.6.linux2_6.$ARC.tar.gz  -C /

useradd zabbix -s /sbin/nologin

touch /var/log/zabbix_agentd.log

chown zabbix /var/log/zabbix_agentd.log

mkdir /etc/zabbix

wget http://pastebin.com/download.php?i=JxWEEPS2 -O /etc/zabbix/zabbix_agentd.conf

sed -i s/^Hostname=.*$/Hostname=$(hostname)/ /etc/zabbix/zabbix_agentd.conf

wget -O /etc/init.d/zabbix_agentd http://pastebin.com/download.php?i=LYAzgDvr

chmod 755 /etc/init.d/zabbix_agentd

sed -i 's/\r$//' /etc/init.d/zabbix_agentd 
sed -i 's/\r$//' /etc/zabbix/zabbix_agentd.conf

/etc/init.d/zabbix_agentd start

chkconfig zabbix_agentd on

if [ -f /etc/csf/csf.conf ]; then
	echo "115.84.182.205" >> /etc/csf/csf.allow
	echo "115.84.182.205" >> /etc/csf/csf.ignore
	csf -r
fi

echo "Done..."
