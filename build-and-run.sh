#!/bin/bash

docker build --rm -t net-sec/dnssec ./
docker rm -f dnssec
docker run -itd \
	-v $(pwd)/exampleDomains:/domains \
	-v $(pwd)/domainKeys:/var/bind/keys \
	-p 53:53/tcp \
	-p 53:53/udp \
	--name dnssec net-sec/dnssec
