FROM quay.io/net-sec/python:latest

# install needed packages
RUN apk add --no-cache bind
RUN apk add --no-cache bind-tools
RUN apk add --no-cache bind-dnssec-tools
RUN apk add --no-cache haveged
RUN apk add --no-cache py3-jinja2
RUN apk add --no-cache py3-yaml

# mkzone
RUN wget https://raw.githubusercontent.com/kolobus/mkzone/refs/heads/master/mkzone -O /mkzone
RUN chmod +x /mkzone

# copy config and set permissions
COPY --chown=named:named named.conf /etc/bind/named.conf
COPY --chown=named:named named.conf.default-zones /etc/bind/named.conf.default-zones
COPY --chown=named:named named.conf.dn42.options /etc/bind/named.conf.dn42.options
COPY --chown=named:named named.conf.dn42.zones /etc/bind/named.conf.dn42.zones
COPY --chown=named:named entrypoint.sh /entrypoint.sh

# make entrypoint executable
RUN chmod +x /entrypoint.sh
# setup permissions to run bind in user space
RUN chown -R named: /var/bind /etc/bind

# ports exposed
EXPOSE 5353/tcp
EXPOSE 5353/udp

# default environment variables
ENV ALLOW_RECURSION_IP=10.0.0.0/8
ENV FORWARDER_1=1.1.1.1
ENV FORWARDER_2=1.0.0.1
ENV FORWARDER_3=2606:4700:4700::1111
ENV FORWARDER_4=2606:4700:4700::1001
ENV DNSSEC=true
ENV SALT=7d70b91db47137cd
ENV DN42=false

USER named

ENTRYPOINT ["/entrypoint.sh"]
