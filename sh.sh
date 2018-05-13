#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
echo "Aguarde..." 
sleep 20

# Zera as regras
iptables -t filter -F
iptables -t filter -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Carrega os modulos
modprobe ip_tables
modprobe iptable_nat
modprobe ip_nat_ftp
modprobe ip_conntrack
modprobe ip_conntrack_ftp

#Ativar o encaminhamento de pacotes
echo "1" > /proc/sys/net/ipv4/ip_forward

#Ativar o compartilhamento de internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#Politica de acesso 
iptables -P FORWARD DROP

#Iniciando o openfire
/etc/init.d/openfire start 

lan=$(echo "192.168.3.0/24")

#Liberando ips do setor de T.I
for interface in $(cat /opt/interfaces)
do
for ipsti in $(uniq /opt/ipsti)
do
iptables -A FORWARD -i $interface -s $ipsti -j ACCEPT
iptables -A FORWARD -o $interface -d $ipsti -j ACCEPT
done
done

#Bloqueando url's
for interface in $(cat /opt/interfaces)
do
for lista in $(uniq /opt/url)
do
iptables -A FORWARD -i $interface -m string --algo bm --string $lista -j REJECT
done
done

for interface in $(cat /opt/interfaces)
do
iptables -A FORWARD -i $interface -s $lan -j ACCEPT
iptables -A FORWARD -o $interface -d $lan -j ACCEPT
done

### Conexoes estabelecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT
#iptables -A FORWARD -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT

#Bloqueando ping pra rede externa
iptables -t filter -A INPUT -s $lan -d 192.168.3.1 -p icmp -j ACCEPT
iptables -t filter -A INPUT -s 192.168.3.1 -d $lan -p icmp -j ACCEPT
iptables -t filter -A INPUT -p icmp -j DROP

echo "Feito!"
exit 0
