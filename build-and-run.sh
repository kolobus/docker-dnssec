#!/bin/bash

docker build --rm -t net-sec/dnssec ./
docker rm -f dnssec

# a real salt can be derrived from
# head -c 1000 /dev/random | sha1sum | cut -b 1-16
docker run -itd \
	-v $(pwd)/exampleDomains:/domains:z \
	-v $(pwd)/domainKeys:/var/bind/keys:z \
    -e SALT=very-secret-salty-string \
	-p 5353:53/tcp \
	-p 5354:53/udp \
	--name dnssec net-sec/dnssec
