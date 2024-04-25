#!/bin/sh
# This script is executed at boot time after VyOS configuration is fully applied.
# Any modifications required to work around unfixed bugs
# or use services not available through the VyOS CLI system can be placed here.

#
/usr/sbin/modprobe ip_tables
/usr/sbin/modprobe ip_conntrack
/usr/sbin/modprobe iptable_filter
/usr/sbin/modprobe iptable_mangle
/usr/sbin/modprobe iptable_nat
/usr/sbin/modprobe ipt_LOG
/usr/sbin/modprobe ipt_limit
/usr/sbin/modprobe ipt_state

#setup unbound
useradd -d/etc/unbound -s/usr/sbin/nologin unbound
systemctl start unbound

useradd -d/var/lib/sing-box -s/usr/sbin/nologin box
systemctl start sing-box@tp

ip route add local default dev lo table 100
ip rule add fwmark 1 table 100

/usr/sbin/iptables-legacy -t mangle -N BOX
/usr/sbin/iptables-legacy -t mangle -A BOX -d 0.0.0.0/8 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 10.0.0.0/8 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 100.64.0.0/10 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 127.0.0.0/8 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 169.254.0.0/16 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 172.16.0.0/12 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 192.0.0.0/24 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 224.0.0.0/4 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 240.0.0.0/4 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 255.255.255.255/32 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 192.168.0.0/16 -p tcp  -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -d 192.168.0.0/16 -p udp  -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX -p tcp -j TPROXY --on-ip 127.0.0.1 --on-port 1536 --tproxy-mark 1
/usr/sbin/iptables-legacy -t mangle -A BOX -p udp -j TPROXY --on-ip 127.0.0.1 --on-port 1536 --tproxy-mark 1
/usr/sbin/iptables-legacy -t mangle -A PREROUTING -j BOX



/usr/sbin/iptables-legacy  -t mangle -N BOX_LOCAL
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 0.0.0.0/8 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 127.0.0.0/8 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 10.0.0.0/8 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 172.16.0.0/12 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 192.168.88.0/24 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 169.254.0.0/16 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 224.0.0.0/4 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 240.0.0.0/4 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -d 255.255.255.255/32 -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX_LOCAL -d 192.168.0.0/16 -p tcp  -j RETURN
/usr/sbin/iptables-legacy -t mangle -A BOX_LOCAL -d 192.168.0.0/16 -p udp  -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -m mark --mark 233 -j RETURN
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -p tcp -j MARK --set-mark 1
/usr/sbin/iptables-legacy  -t mangle -A BOX_LOCAL -p udp -j MARK --set-mark 1



iptables -t mangle -A OUTPUT -j BOX_LOCAL

# FULLCONENAT Rules
/usr/sbin/iptables-legacy -t nat -I POSTROUTING -o pppoe0 -j FULLCONENAT
/usr/sbin/iptables-legacy -t nat -I PREROUTING -i pppoe0 -j FULLCONENAT
/usr/sbin/iptables-legacy -t nat -I PREROUTING -i eth0 -j FULLCONENAT
