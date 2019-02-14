#!/bin/bash

docker build --rm -t net-sec/dns ./
docker rm -f dns
docker run -itd -p 53:53/tcp -p 53:53/udp --name dns net-sec/dns