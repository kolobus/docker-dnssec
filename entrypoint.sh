#!/bin/bash

# if [ $dnssec == true ]
# 	dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $main_domain
# fi

# replace recursion ip
sed -i -E "s|<ALLOW_RECURSION_IP>|${ALLOW_RECURSION_IP}|g" /etc/bind/named.conf

# replace forwarder ips
FORWARDER=''
for var in $(compgen -A variable | grep -E 'FORWARDER_[0-9]{1,3}'); do
	FORWARDER="${FORWARDER}\t\t${!var};\n"
done
sed -i -E "s|<FORWARDER>|${FORWARDER}|g" /etc/bind/named.conf

mkdir -p /var/bind/zones
if [ -d "/domains" ]
then
	for zonefile in $(ls /domains/*.yaml); do
		domain=$(echo $zonefile | sed -E "s|/domains/||g" | sed -E "s|.yaml||g")
		/mkzone $zonefile >> /var/bind/zones/${domain}.zone

		echo "zone \"${domain}\" {" >> /etc/bind/named.conf.zones
		echo "  type master;" >> /etc/bind/named.conf.zones
		echo "  file \"zones/${domain}.zone\";" >> /etc/bind/named.conf.zones
		echo "};" >> /etc/bind/named.conf.zones
		echo "" >> /etc/bind/named.conf.zones
		echo $zonefile
		echo $domain
	done
fi

chown -R named: /var/bind/zones

# start named with given config
/usr/sbin/named -f -u named -c /etc/bind/named.conf
