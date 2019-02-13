FROM alpine:latest

COPY named.conf /etc/bind/named.conf

RUN apk add bind
RUN apk add bind-tools

RUN chown named: /etc/bind/named.conf

EXPOSE 53/tcp
EXPOSE 53/udp

ENV dnssec=true
#ENV main_domain=example.com

#USER named
ENTRYPOINT ["/usr/sbin/named", "-f", "-c", "/etc/bind/named.conf"]
