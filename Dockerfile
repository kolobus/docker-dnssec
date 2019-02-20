FROM alpine:latest

# install needed packages
RUN apk add --no-cache bind
RUN apk add --no-cache bind-tools
RUN apk add --no-cache bash
RUN apk add --no-cache python3
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade jinja2
RUN pip3 install --upgrade pyyaml
RUN wget https://raw.githubusercontent.com/mfs/mkzone/master/mkzone -O /mkzone
RUN chmod +x /mkzone

# copy config and set permissions
COPY named.conf /etc/bind/named.conf
COPY named.conf.default-zones /etc/bind/named.conf.default-zones
COPY entrypoint.sh /entrypoint.sh

RUN chown named: /etc/bind/named.conf*
RUN chmod +x /entrypoint.sh

# ports exposed
EXPOSE 53/tcp
EXPOSE 53/udp

# default environment variables
ENV ALLOW_RECURSION_IP=172.17.0.0/24
ENV FORWARDER_1=208.67.222.222
ENV FORWARDER_2=208.67.220.220

#USER named

ENTRYPOINT ["/entrypoint.sh"]
