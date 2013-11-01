#!/bin/bash

NGINXV="nginx-1.4.2"
NGINXPUREV="ngx_cache_purge-2.1"
DIR="/usr/local/src"
ARC=`uname -a | awk '{print $12}'`
cd $DIR
wget http://nginx.org/download/$NGINXV.tar.gz
wget http://labs.frickle.com/files/$NGINXPUREV.tar.gz
wget --no-check-certificate -O yuri-gushin-Roboo-00e2779.zip https://github.com/yuri-gushin/Roboo/zipball/master
yum install pcre-devel openssl openssl-devel gcc gcc-c++ -y
tar xf $NGINXV.tar.gz
tar xf $NGINXPUREV.tar.gz
unzip yuri-gushin-Roboo-00e2779.zip
cd $NGINXV

./configure  --add-module=../$NGINXPUREV --sbin-path=/usr/local/sbin  --pid-path=/var/run/nginx.pid --conf-path=/etc/nginx/nginx.conf  --error-log-path=/var/log/nginx/error.log  --http-log-path=/var/log/nginx/access.log  --with-http_realip_module  --with-http_ssl_module  --http-client-body-temp-path=/tmp/nginx_client  --http-proxy-temp-path=/tmp/nginx_proxy  --http-fastcgi-temp-path=/tmp/nginx_fastcgi  --with-http_stub_status_module --with-http_perl_module

make && make install

wget -O /etc/init.d/nginx http://pastebin.com/raw.php?i=pKUjVp8n

sed -i 's/\r$//' /etc/init.d/nginx

chmod u+x /etc/init.d/nginx

cd $DIR

wget http://pkgs.repoforge.org/perl-Math-Pari/perl-Math-Pari-2.01080603-1.el5.rf.$ARC.rpm
# http://pkgs.repoforge.org/perl-Math-Pari/perl-Math-Pari-2.01080603-1.el6.rf.x86_64.rpm

rpm -ivh perl-Math-Pari-2.01080603-1.el5.rf.$ARC.rpm 

wget http://pkgs.repoforge.org/perl-Class-Loader/perl-Class-Loader-2.03-1.2.el5.rf.noarch.rpm
# http://pkgs.repoforge.org/perl-Class-Loader/perl-Class-Loader-2.03-1.2.el6.rf.noarch.rpm

wget http://pkgs.repoforge.org/perl-Digest-SHA/perl-Digest-SHA-5.71-1.el5.rf.$ARC.rpm
# http://pkgs.repoforge.org/perl-Digest-SHA/perl-Digest-SHA-5.71-1.el6.rfx.x86_64.rpm

wget http://pkgs.repoforge.org/perl-Crypt-Random/perl-Crypt-Random-1.25-1.2.el5.rf.noarch.rpm
# http://pkgs.repoforge.org/perl-Crypt-Random/perl-Crypt-Random-1.25-1.2.el6.rf.noarch.rpm

rpm -ivh perl-Class-Loader-2.03-1.2.el5.rf.noarch.rpm

rpm -ivh perl-Digest-SHA-5.71-1.el5.rf.$ARC.rpm

rpm -ivh perl-Crypt-Random-1.25-1.2.el5.rf.noarch.rpm

cpan install IPC::SharedMem

cpan install Net::IP::Match::Regexp

cpan install Compress::Zlib

cp $DIR/yuri-gushin-Roboo-00e2779/Roboo.pm /usr/local/nginx/

#nginx -t

echo "Install finish"
