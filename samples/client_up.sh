#!/bin/bash

# example client up script
# will be executed when client is up

# all key value pairs in ShadowVPN config file will be passed to this script
# as environment variables, except password

# turn on IP forwarding
sysctl -w net.ipv4.ip_forward=1

# configure IP address and MTU of VPN interface
ifconfig $intf 10.7.0.2 netmask 255.255.255.0
ifconfig $intf mtu $mtu

# turn on NAT over VPN and eth0
# if you use other interface name that eth0, replace eth0 with it
iptables -t nat -A POSTROUTING -o $intf -j MASQUERADE
iptables -A FORWARD -i $intf -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o $intf -j ACCEPT

# get current gateway
echo reading old gateway from route table
old_gw=`ip route show | grep '^default' | sed -e 's/default via \([^ ]*\).*/\1/'`

# if current gateway is 10.7.0.1, it indicates that our gateway is already changed
# read from saved file
if [ $old_gw == 10.7.0.1 ]; then
  echo reading old gateway from /tmp/old_gw
  old_gw=`cat /tmp/old_gw` || ( echo "can not read gateway, check up.sh" && exit 1 )
fi

echo saving old gateway to /tmp/old_gw
echo $old_gw > /tmp/old_gw

# change routing table
echo changing default route
route add $server gw $old_gw
route del default
route add default gw 10.7.0.1
echo default route changed to 10.7.0.1

############################################
# insert chnroutes rules here if you need! #
############################################

echo $0 done
