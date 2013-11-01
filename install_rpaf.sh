#!/bin/bash


wget http://fossies.org/unix/www/apache_httpd_modules/mod_rpaf-0.6.tar.gz

tar xf mod_rpaf-0.6.tar.gz

cd mod_rpaf-0.6

/usr/local/apache/bin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c

cat << EOF >> /usr/local/apache/conf/extra/httpd-rpaf.conf
LoadModule rpaf_module modules/mod_rpaf-2.0.so
#Mod_rpaf settings
RPAFenable On
RPAFproxy_ips 125.253.122.12
RPAFsethostname On
RPAFheader X-Real-IP
EOF

echo "Include conf/extra/httpd-rpaf.conf" >> /usr/local/apache/conf/httpd.conf
/etc/init.d/httpd restart

echo "Install finish"
