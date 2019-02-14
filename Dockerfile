FROM alpine:latest

COPY named.conf /etc/bind/named.conf
COPY entrypoint.sh /entrypoint.sh

RUN apk add bind
RUN apk add bind-tools

RUN chown named: /etc/bind/named.conf
RUN chmod +x /entrypoint.sh

EXPOSE 53/tcp
EXPOSE 53/udp

ENV ALLOW_RECURSION_IP=172.17.0.0/24
ENV FORWARDER_1=208.67.222.222
ENV FORWARDER_2=208.67.220.220
ENV dnssec=true
#ENV main_domain=example.com

#USER named
ENTRYPOINT ["/entrypoint.sh"]
