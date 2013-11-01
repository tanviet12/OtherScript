#!/bin/bash

NGINXV="nginx-1.2.2"
NGINXPUREV="ngx_cache_purge-1.5"
DIR="/usr/local/src"

cd $DIR
wget http://nginx.org/download/$NGINXV.tar.gz
wget http://labs.frickle.com/files/$NGINXPUREV.tar.gz

tar xf $NGINXV.tar.gz
tar xf $NGINXPUREV.tar.gz

cd $NGINXV

 ./configure  --add-module=../$NGINXPUREV --sbin-path=/usr/local/sbin  --conf-path=/etc/nginx/nginx.conf  --error-log-path=/var/log/nginx/error.log  --http-log-path=/var/log/nginx/access.log  --with-http_realip_module  --with-http_ssl_module  --http-client-body-temp-path=/tmp/nginx_client  --http-proxy-temp-path=/tmp/nginx_proxy  --http-fastcgi-temp-path=/tmp/nginx_fastcgi  --with-http_stub_status_module

make && make install

wget -O /etc/init.d/nginx http://dev11.vinahost.vn/resource/nginx

chmod u+x /etc/init.d/nginx

cd /etc/

rm -rf nginx

ln -s /nfs/config/nginx /etc/nginx

cd $DIR

wget http://stderr.net/apache/rpaf/download/mod_rpaf-0.6.tar.gz

tar xf mod_rpaf-0.6.tar.gz

cd mod_rpaf-0.6

/usr/sbin/apxs -i -c -n mod_rpaf-2.0.so mod_rpaf-2.0.c

cat << EOF >> /etc/httpd/conf/rpaf.conf
LoadModule rpaf_module modules/mod_rpaf-2.0.so
#Mod_rpaf settings
RPAFenable On
RPAFproxy_ips 123.30.129.181
RPAFsethostname On
RPAFheader X-Real-IP
EOF

echo "Include conf/rpaf.conf"
/etc/init.d/httpd restart

echo "Install finish"


./configure --add-module=../ngx_cache_purge-1.5 --sbin-path=/usr/local/sbin --prefix=/etc/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-debug --with-http_addition_module --with-http_dav_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-ipv6 --with-sha1=/usr/include/openssl --with-md5=/usr/include/openssl --with-http_perl_module
