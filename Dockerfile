FROM alpine:3.12

LABEL maintainer="Daniil Trishkin <asteroid566@gmail.com>"

ADD ./patches /mtproxy/patches
ADD ./start.sh /mtproxy/
RUN apk update && apk add --no-cache git curl build-base openssl-dev linux-headers supervisor zlib-dev
RUN git clone --single-branch --depth 1 https://github.com/TelegramMessenger/MTProxy.git /mtproxy/sources && \
cd /mtproxy/sources && patch -p0 -i /mtproxy/patches/randr_compat.patch && make && \
mv /mtproxy/sources/objs/bin/mtproto-proxy /mtproxy
RUN mkdir -p {/etc/supervisor.d,/etc/crontabs}
ADD ./crontab /etc/crontabs/root
ADD ./prepare.sh /opt/prepare.sh
ADD supervisor-mtproxy.conf /etc/supervisor.d/supervisor-mtproxy.ini

WORKDIR /mtproxy

ENTRYPOINT supervisord -c /etc/supervisord.conf
