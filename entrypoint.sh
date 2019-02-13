#!/bin/sh

# if [ $dnssec == true ]
# 	dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $main_domain
# fi

/usr/sbin/named -f -c /etc/bind/named.conf.recursive
