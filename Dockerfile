FROM quay.io/net-sec/python:latest

# install needed packages
RUN apk add --no-cache bind
RUN apk add --no-cache bind-tools
RUN apk add --no-cache bind-dnssec-tools
RUN apk add --no-cache haveged
RUN pip3 install --upgrade jinja2
RUN pip3 install --upgrade pyyaml
RUN wget https://raw.githubusercontent.com/claudio-walser/mkzone/master/mkzone -O /mkzone
RUN chmod +x /mkzone

# copy config and set permissions
COPY --chown=named:named named.conf /etc/bind/named.conf
COPY --chown=named:named named.conf.default-zones /etc/bind/named.conf.default-zones
COPY --chown=named:named entrypoint.sh /entrypoint.sh

# make entrypoint executable
RUN chmod +x /entrypoint.sh
# setup permissions to run bind in user space
RUN chown -R named: /var/bind /etc/bind

# ports exposed
EXPOSE 5353/tcp
EXPOSE 5353/udp

# default environment variables
ENV ALLOW_RECURSION_IP=10.0.2.0/24
ENV FORWARDER_1=208.67.222.123
ENV FORWARDER_2=208.67.220.123
ENV DNSSEC=true
ENV SALT=7d70b91db47137cd

USER named

ENTRYPOINT ["/entrypoint.sh"]
