#!/bin/bash

# if [ $dnssec == true ]
# 	dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $main_domain
# fi

echo $DNSSEC

# replace recursion ip
sed -i -E "s|<ALLOW_RECURSION_IP>|${ALLOW_RECURSION_IP}|g" /etc/bind/named.conf

# replace forwarder ips
FORWARDER=''
for var in $(compgen -A variable | grep -E 'FORWARDER_[0-9]{1,3}'); do
	FORWARDER="${FORWARDER}\t\t${!var};\n"
done
sed -i -E "s|<FORWARDER>|${FORWARDER}|g" /etc/bind/named.conf

DNSSEC_STRING=''
if [ $DNSSEC = "true" ]
then
	DNSSEC_STRING="${DNSSEC_STRING}\tdnssec-validation yes;\n"
fi

sed -i -E "s|<DNSSEC>|${DNSSEC_STRING}|g" /etc/bind/named.conf

mkdir -p /var/bind/keys
mkdir -p /var/bind/zones
mkdir -p /etc/bind/zones-enabled
if [ -d "/domains" ]
then
	for zonefile in $(ls /domains/*.yaml); do
		domain=$(echo $zonefile | sed -E "s|/domains/||g" | sed -E "s|.yaml||g")
		# write zone file
		/mkzone $zonefile > /var/bind/zones/${domain}.zone

		# write zone config
		echo "zone \"${domain}\" {" > /etc/bind/zones-enabled/${domain}.conf.zone
		echo "  type master;" >> /etc/bind/zones-enabled/${domain}.conf.zone
		echo "  file \"zones/${domain}.zone\";" >> /etc/bind/zones-enabled/${domain}.conf.zone
		echo "};" >> /etc/bind/zones-enabled/${domain}.conf.zone
		echo "" >> /etc/bind/zones-enabled/${domain}.conf.zone

		# include zone config
		echo "include \"/etc/bind/zones-enabled/${domain}.conf.zone\";" >> /etc/bind/named.conf

		# create zone signing key
		if [ $DNSSEC = "true" ]
		then
			cd /var/bind/keys
			# zone signing key
			grep "This is a zone-signing key" ./K${domain}.*.key
			if [ $? != 0 ]
			then
				dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE ${domain}
			fi

			# key signing key
			grep "This is a key-signing key" ./K${domain}.*.key
			if [ $? != 0 ]
			then
				dnssec-keygen -f KSK -a NSEC3RSASHA1 -b 4096 -n ZONE ${domain}
			fi

			# include keys
			for key in `ls K${domain}.*.key`
			do
				echo "\$INCLUDE /var/bind/keys/${key}">> /var/bind/zones/${domain}.zone
			done
			cd -

			# sign zone
			cd /var/bind/zones
			if [ ! -f ${domain}.zone.signed ]
			then
				dnssec-signzone -3 $SALT -A -N INCREMENT -K /var/bind/keys -o ${domain} -t ${domain}.zone
			fi

			# use signed zone file now
			sed -i -E "s|file \"zones/${domain}.zone\";|file \"zones/${domain}.zone.signed\";|g" /etc/bind/zones-enabled/${domain}.conf.zone
			cd -
		fi
	done
fi

chown -R named: /var/bind/zones
chown -R named: /etc/bind/zones-enabled

# start named with given config
/usr/sbin/named -f -u named -c /etc/bind/named.conf


sleep 500000