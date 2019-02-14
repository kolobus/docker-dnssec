#!/bin/sh

# if [ $dnssec == true ]
# 	dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $main_domain
# fi

sed -i "s/\<ALLOW_RECURSION_IP>/$ALLOW_RECURSION_IP/g" /etc/bind/named.conf

/usr/sbin/named -f -c /etc/bind/named.conf
