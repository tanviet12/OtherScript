#!/usr/local/bin/bash

# Default variable
WHILELIST_IP="IP(64.233.160.0/19),IP(66.102.0.0/20),IP(66.249.64.0/19),IP(72.14.192.0/18),IP(74.125.0.0/16),IP(209.85.128.0/17),IP(216.239.32.0/19),IP(64.4.0.0/18),IP(65.52.0.0/14),IP(157.56.0.0/14),IP(157.60.0.0/16),IP(157.54.0.0/15),IP(207.46.0.0/16),IP(207.68.128.0/18),IP(207.68.192.0/20),IP(8.0.0.0/8),IP(66.196.64.0/18),IP(66.228.160.0/19),IP(67.195.0.0/16),IP(68.142.192.0/18),IP(72.30.0.0/16),IP(74.6.0.0/16),IP(209.191.64.0/18),IP(202.160.176.0/20), IP(112.78.5.6/32), IP(202.43.109.139/32),IP(115.84.182.196)"
ROBOO=1
LIMIT_REQUEST_RATE=7

# Print help
VNHHelp()
{

cat << EOH >&2
  Usage: $0 :
  $0 [options1] [options2] [optionn]  
  with following options (in that order)
	$0 -h [--help]    					Print this message
	$0 -n [--domain] exam.com    				Domain for virtualhost
	$0 -b [--backend] 123.30.129.91:80			IP:PORT of backend server
	$0 -d [--disable-roboo]       				This option will disable roboo. By default, roboo is enable
	$0 -w [--while-list-ip] "IP(6.23.16.0/19),IP(...),.."	List ip while list
	$0 -r [--rate-limit] 5					Limit request/s. 5 request/s . Burst set default = 7
	$0 -e [--remove-vhost]					Remove virtualhost
  Example:
	$0 -n khachhang.com -b 210.211.110.180:80 -w "IP(64.233.160.0/19),IP(66.102.0.0/20),IP(66.249.64.0/19)" -r 6
	$0 --domain=khachhang.com --backend=210.211.110.189:8081 --while-list-ip="IP(64.233.160.0/19),IP(66.102.0.0/20),IP(66.249.64.0/19)" --rate-limit=19
	$0 --domain=khachhang.com --backend=210.211.110.189:8081 --rate-limit=19 --disable-roboo
	$0 --domain=khachhang.com --remove-vhost
EOH
exit
}

RemoveVhost()
{
	if [ ! $DOMAIN ]; then
		echo " Error!. Please enter domain of virtualhost with --domain. Ex: $0 --domain=khachhang.com --remove-vhost"
		exit
	fi
	cat /dev/null > /usr/local/etc/nginx/vhosts/$DOMAIN
	echo Done.
	exit
}

# Option and argument 
while getopts ':hde-b:-w:-r:n:' OPTION ; do
  case "$OPTION" in
    h  ) VNHHelp                       ;;
    n  ) DOMAIN=$OPTARG                  ;;
    b  ) BACKEND=$OPTARG                       ;;
    d  ) ROBOO=0       		                ;;
    e  ) RemoveVhost       		                ;;
    w  ) WHILELIST_IP=$OPTARG          		            ;;
    r  ) LIMIT_REQUEST_RATE=$OPTARG;LIMIT_REQUEST="limit_req   zone=${DOMAIN}  burst=7;"                       ;;
    -  ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo $OPTION | cut -d'=' -f2)
         OPTION=$(echo $OPTION | cut -d'=' -f1)
         case $OPTION in
             --help      ) VNHHelp                       ;;
             --domain    ) DOMAIN=$OPTARG                     ;;
             --backend   ) BACKEND=$OPTARG                    ;;
             --disable-roboo    ) ROBOO=0                   ;;
             --remove-vhost    ) RemoveVhost                   ;;
             --while-list-ip      ) WHILELIST_IP=$OPTARG        ;;
             --rate-limit      ) LIMIT_REQUEST_RATE=$OPTARG;LIMIT_REQUEST="limit_req   zone=${DOMAIN}  burst=7;"          ;;
             * ) VNHHelp ;;
         esac
       OPTIND=1
       shift
      ;;
    ? ) VNHHelp;;
  esac
done


# Generate virualhost

if [ $ROBOO != 0 ]; then

cat << EOF > /usr/local/etc/nginx/vhosts/$DOMAIN
limit_req_zone  \$binary_remote_addr  zone=${DOMAIN}:10m   rate=${LIMIT_REQUEST_RATE}r/s;
server {
        listen 80;
        server_name ${DOMAIN}  www.${DOMAIN};
        server_name_in_redirect off;
        access_log off;

        location / {
                perl Roboo::handler;
                set \$Roboo_challenge_modes 'JS,gzip';
                set \$Roboo_cookie_name 'vnh_check';
                set \$Roboo_validity_window 14400;
		${OPT_WHILELIST}
		set \$Roboo_whitelist "${WHILELIST_IP}";
                set \$Roboo_charset "UTF-8";
                set \$Roboo_challenge_hash_input \$server_name\$server_port\$http_host\$http_user_agent\$remote_addr;
                error_page 555 = @proxy;
                expires epoch;
                add_header Last-Modified "";
	
		${LIMIT_REQUEST}

                if (\$Roboo_challenge_modes ~ gzip) {
                        gzip on;
                }
                access_log /var/log/nginx/${DOMAIN}-challenged.log;
        }

        location @proxy {
                include proxy.inc;
                gzip on;
                access_log /var/log/nginx/${DOMAIN}-verified.log;
                proxy_pass http://${BACKEND};
        }
}
EOF

else

cat << EOF > /usr/local/etc/nginx/vhosts/$DOMAIN
limit_req_zone  \$binary_remote_addr  zone=${DOMAIN}:10m   rate=${LIMIT_REQUEST_RATE}r/s;
server {
        listen 80;
        server_name ${DOMAIN}  www.${DOMAIN};
        server_name_in_redirect off;
        access_log off;

        location / {
                include proxy.inc;
                gzip on;
                access_log /var/log/nginx/${DOMAIN}-verified.log;
                proxy_pass http://${BACKEND};
		${LIMIT_REQUEST}
        }
}
EOF

fi
