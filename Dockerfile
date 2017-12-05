#
# Dockerfile for ProxyHub
#

FROM resin/rpi-raspbian:latest
MAINTAINER Bruno Cardoso Cantisano <bruno.cantisano@gmail.com>

ENV LIBSODIUM_VERSION=1.0.12
ENV DNSCRYPT-PROXY_VERSION=1.4.3

RUN apt-get update
RUN apt-get install -y build-essential pdnsd haproxy polipo nginx python
RUN apt-get clean

ADD files/haproxy.cfg /etc/haproxy/
ADD files/pdnsd.conf /etc/
ADD files/polipo.conf /etc/polipo/config
ADD files/shadowsocks.json /etc/
ADD files/supervisord.conf /etc/supervisor/
ADD files/services.ini /etc/supervisor/conf.d/

ADD http://stedolan.github.io/jq/download/linux64/jq /usr/local/bin/
ADD https://bootstrap.pypa.io/get-pip.py /tmp/pkgs/
ADD https://download.libsodium.org/libsodium/releases/libsodium-${LIBSODIUM_VERSION}.tar.gz /tmp/pkgs/
ADD http://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-proxy-${DNSCRYPT-PROXY_VERSION}.tar.gz /tmp/pkgs/

WORKDIR /tmp/pkgs/
RUN chmod +x /usr/local/bin/jq
RUN python get-pip.py
RUN pip install supervisor shadowsocks
RUN tar xzf libsodium-${LIBSODIUM_VERSION}.tar.gz && \
    cd libsodium-${LIBSODIUM_VERSION} && \
    ./configure && \
    make && \
    make install
RUN echo /usr/local/lib > /etc/ld.so.conf.d/local.conf && ldconfig
RUN tar xzf dnscrypt-proxy-${DNSCRYPT-PROXY_VERSION}.tar.gz && \
    cd dnscrypt-proxy-${DNSCRYPT-PROXY_VERSION} && \
    ./configure && \
    make && \
    make install

WORKDIR /
RUN rm -r /tmp/pkgs/
EXPOSE 53/udp 53/tcp 80 1080 8123 9001

CMD supervisord -n -c /etc/supervisor/supervisord.conf
