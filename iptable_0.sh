IF=`/sbin/route | grep -i 'default' | awk '{print$8}'`
IP=`/sbin/ifconfig $IF | grep "inet addr" | awk -F":" '{print$2}' | awk '{print $1}'`
LOIF="lo"
LOIP="127.0.0.1"
IPT="/sbin/iptables"
NET="any/0"
DNS="8.8.8.8 203.162.0.181"
SERV_TCP="80 25 587 465 5050"
SERV_UDP="53"
HI_PORTS="1024:65535"
OK_ICMP="0 3 4 8 11"
$IPT -F
$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

$IPT -A INPUT -i $LOIF -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -o $LOIF -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

#ICMP Type accept
for item in $OK_ICMP; do
$IPT -A INPUT -i $IF -s $NET -p icmp --icmp-type $item -j ACCEPT
$IPT -A OUTPUT -o $IF -s $IP -p icmp --icmp-type $item -j ACCEPT
done

#DROP PACKET FIN-RST - #DROP PACKET PORT SCAN(syn-fin)
$IPT -A INPUT -i $IF -s $IP -d $IP -m limit --limit 1/s -j LOG --log-prefix "PORT SCAN: "
$IPT -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags ACK,FIN FIN -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags ACK,URG URG -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags ACK,PSH PSH -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags ALL NONE  -s $NET -j DROP
$IPT -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -s $NET -j DROP

#DROP PACKET SPOOFING IP
$IPT -A INPUT -i $IF -s $IP -d $IP -m limit --limit 1/s -j LOG --log-prefix "SPOOFING: "
$IPT -A INPUT -i $IF -s $IP -d $IP -j DROP

#UDP FLOOD
#$IPT -A INPUT -i $IF -p udp -s $NET --sport $port -d $IP --dport $port -m state --state NEW,ESTABLISHED -m limit --limit 2/s --limit-burst 2 -j ACCEPT
#$IPT -A OUTPUT -o $IF -p udp -s $IP --sport $port -d $NET --dport $port -m state --state ESTABLISHED -m limit --limit 2/s --limit-burst 2 -j ACCEPT
#DROP PACKET INVALID  and LOG
$IPT -A INPUT -m state --state INVALID -mlimit --limit 1/s -j LOG --log-prefix "INVALID_STATE: " 
$IPT -A INPUT -m state --state INVALID -j DROP

for entry in $DNS; do
$IPT -A OUTPUT -o $IF -p udp -s $IP --sport $HI_PORTS -d $entry --dport 53 -m state --state NEW -j ACCEPT
$IPT -A INPUT -i $IF -p udp -s $entry --sport 53 -d $IP --dport $HI_PORTS -m state --state ESTABLISHED -j ACCEPT
done

#for port in $SERV_UDP; do
#if test $port -eq 53
#then
#$IPT -A INPUT -i $IF -p udp -s $NET --sport $port -d $IP --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT
#$IPT -A OUTPUT -o $IF -p udp -s $IP --sport $port -d $NET --dport $port -m state --state ESTABLISHED -j ACCEPT
#else
#UDP FLOOD
#$IPT -A INPUT -i $IF -p udp -s $NET --sport $port -d $IP --dport $port -m state --state NEW,ESTABLISHED -m limit --limit 2/s --limit-burst 2 -j ACCEPT
#$IPT -A OUTPUT -o $IF -p udp -s $IP --sport $port -d $NET --dport $port -m state --state ESTABLISHED -m limit --limit 2/s --limit-burst 2 -j ACCEPT
#$IPT -A INPUT -i $IF -p udp -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -j ACCEPT
#$IPT -A OUTPUT -o $IF -p udp -s $IP --sport $port -d $NET --dport $HI_PORTS -m state --state ESTABLISHED -j ACCEPT
#fi
#done
 
$IPT -t mangle -N blockip
$IPT -t mangle -A blockip -j DROP
$IPT -N SYN_CHECK
$IPT -A SYN_CHECK -m recent --set --name SYN

#FTP 
$IPT -A INPUT -p tcp -s $NET --sport 1024:65535 -d $IP --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -p tcp -s $IP --sport 21 -d $NET --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPT -A INPUT -p tcp -s $NET --sport 1024:65535 -d $IP --dport 1024:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A OUTPUT -p tcp -s $IP --sport 1024:65535 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
$IPT -A OUTPUT -p tcp -s $IP --sport 20 -d $NET --dport 1024:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT
$IPT -A INPUT -p tcp -s $NET --sport 1024:65535 -d $IP --dport 20 -m state --state ESTABLISHED -j ACCEPT

 for port in $SERV_TCP; do
$IPT -A INPUT -p tcp ! --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -m limit --limit 1/s -j LOG --log-prefix "INVALID_SERVICE_REQUEST: "
#$IPT -A INPUT -p tcp ! --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -j DROP

#CONNECTION LIMIT

$IPT -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -m length --length 40:60 -m connlimit ! --connlimit-above 25 -j ACCEPT

#PACKET RAGE LIMIT
#$IPT -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m limit --limit 4/s --limit-burst 25 -m state --state NEW -m length --length 40:60 -j SYN_CHECK
$IPT -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -m length --length 40:60 -j SYN_CHECK
$IPT -A SYN_CHECK -m recent --update --seconds 60 --hitcount 20 --name SYN -j LOG --log-prefix "FLOOD: "
$IPT -A SYN_CHECK -m recent --update --seconds 60 --hitcount 20 --name SYN -j DROP
$IPT -A SYN_CHECK -m recent --update --seconds 60 --hitcount 20  --name SYN -j ACCEPT

#$IPT -A INPUT -i $IF -p tcp --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state NEW -m length --length 40:60 -j ACCEPT

#Connect out network
$IPT -A OUTPUT -o $IF -p tcp -s $IP --sport $HI_PORTS -d $NET --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT
$IPT -A INPUT -i $IF -p tcp ! --syn -s $NET --sport $port -d $IP --dport $HI_PORTS -m state --state ESTABLISHED -j ACCEPT

$IPT -A OUTPUT -o $IF -p tcp ! --syn -s $IP --sport $port -d $NET --dport $HI_PORTS -m state --state ESTABLISHED -j ACCEPT
$IPT -A INPUT -i $IF -p tcp ! --syn -s $NET --sport $HI_PORTS -d $IP --dport $port -m state --state ESTABLISHED -j ACCEPT
if test $port -eq 80
then
$IPT -t mangle -A PREROUTING -p tcp -s $NET --sport $HI_PORTS -d $IP --dport $port -m recent --hitcount 20 --name SYN --update --seconds 180 -j blockip
fi
done




#$IPT -A INPUT -i $IF -p tcp --tcp-flags PSH,ACK PSH,ACK -s $NET --sport $HI_PORTS -d $IP --dport 80 -m limit --limit 3/s --limit-burst 5  -j ACCEPT
$IPT -A INPUT -i $IF -d $IP -m limit --limit 1/s -j LOG --log-level 5 --log-prefix "BAD_INPUT: "
$IPT -A INPUT -i $IF -d $IP -j DROP
$IPT -A OUTPUT -o $IF -d $IP -m limit --limit 1/s -j LOG --log-level 5 --log-prefix "BAD_OUTPUT: "
$IPT -A OUTPUT -o $IF -d $IP -j DROP
$IPT -A FORWARD -i $IF -d $IP -m limit --limit 1/s -j LOG --log-level 5 --log-prefix "BAD_FORWARD: "
$IPT -A FORWARD -i $IF -d $IP -j DROP

