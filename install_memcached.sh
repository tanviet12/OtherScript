#!/bin/bash
#Vietbt

DIR="/usr/local/src/memcache"
MEMCACHED_VERSION="1.4.15"
MEMCACHE_VERSION="2.2.7"
DIR_PHP_BIN="/usr/local/bin"
PATH_PHP_INI="/usr/local/lib/php.ini"

mkdir -p $DIR



#Compile and Install LibEvent
echo "Compile and Install LibEvent.........."

cd $DIR
wget http://www.monkey.org/~provos/libevent-1.4.9-stable.tar.gz
tar xf libevent-1.4.9-stable.tar.gz
cd libevent-1.4.9-stable
./configure; make; make install

#Compile and Install Memcached
echo "Compile and Install Memcached.........."
cd $DIR
wget http://memcached.googlecode.com/files/memcached-$MEMCACHED_VERSION.tar.gz
tar xf memcached-$MEMCACHED_VERSION.tar.gz
cd memcached-$MEMCACHED_VERSION
./configure --with-lib-event=/usr/local/; make; make install

#Installing PHP Memcache
echo "Installing PHP Memcache.........."
cd $DIR
wget http://pecl.php.net/get/memcache-$MEMCACHE_VERSION.tgz
tar xf memcache-$MEMCACHE_VERSION.tgz
cd memcache-$MEMCACHE_VERSION
$DIR_PHP_BIN/phpize

./configure --with-php-config=$DIR_PHP_BIN/php-config; make; make install

echo "extension=memcache.so" >>$PATH_PHP_INI

echo "Finish!"

echo "Create the configuration file......"

cat << EOF >> /etc/memcached.conf
#Memory a usar
-m 300
# default port
-p 11211
# user to run daemon nobody/apache/www-data
-u nobody
# only listen locally
-l 127.0.0.1
EOF

echo "Create the startups files......."
wget -O /etc/init.d/memcached http://pastebin.com/raw.php?i=yt26yFDk
sed -i 's/\r$//' /etc/init.d/memcached
chmod +x /etc/init.d/memcached


wget -O /usr/local/bin/start-memcached http://pastebin.com/raw.php?i=ET4pzDYh
chmod +x  /usr/local/bin/start-memcached

sed -i 's/\r$//' /usr/local/bin/start-memcached

echo "Start memcached...."

/etc/init.d/memcached restart

echo "Done"
