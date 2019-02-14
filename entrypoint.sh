#!/bin/bash

# if [ $dnssec == true ]
# 	dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $main_domain
# fi

# checkout as an example
# https://github.com/arc-ts/keepalived/blob/master/skel/init.sh

# replace recursion ip
sed -i -E "s|<ALLOW_RECURSION_IP>|${ALLOW_RECURSION_IP}|g" /etc/bind/named.conf

# replace forwarder ips
FORWARDER=''
for var in $(compgen -A variable | grep -E 'FORWARDER_[0-9]{1,3}'); do
	FORWARDER="${FORWARDER}\t\t${!var};\n"
done
sed -i -E "s|<FORWARDER>|${FORWARDER}|g" /etc/bind/named.conf

# start named with given config
/usr/sbin/named -f -c /etc/bind/named.conf
