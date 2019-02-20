#!/bin/bash

docker build --rm -t net-sec/dns ./
docker rm -f dns
docker run -itd -v $(pwd)/../coreos-ignitions/domains:/domains -p 53:53/tcp -p 53:53/udp --name dns net-sec/dns
