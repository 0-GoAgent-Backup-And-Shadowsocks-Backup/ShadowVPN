#!/bin/sh

# example client down script
# will be executed when client is down

# all key value pairs in ShadowVPN config file will be passed to this script
# as environment variables, except password

# uncomment if you want to turn off IP forwarding
# sysctl -w net.ipv4.ip_forward=0

# turn off NAT over VPN and eth0
# if you use other interface name that eth0, replace eth0 with it
iptables -t nat -D POSTROUTING -o $intf -j MASQUERADE
iptables -D FORWARD -i $intf -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i eth0 -o $intf -j ACCEPT

# get old gateway
echo reading old gateway from /tmp/old_gw_intf
old_gw_intf=`cat /tmp/old_gw_intf` || ( echo "can not read gateway, check up.sh" && exit 1 )
old_gw_ip=`cat /tmp/old_gw_ip` || ( echo "can not read gateway, check up.sh" && exit 1 )
rm /tmp/old_gw_intf
rm /tmp/old_gw_ip

# change routing table
echo changing default route
route del $server $old_gw_intf
route del default
if [ pppoe-wan = "$old_gw_intf" ]; then
  route add default $old_gw_intf
else
  route add default gw $old_gw_ip
fi
echo default route changed to $old_gw_intf

echo $0 done
