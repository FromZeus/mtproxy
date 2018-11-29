#!/bin/sh

USER_SECRET=$(cat < /data/proxy_pipe)
INTERNAL_IP=$(cat < /data/proxy_pipe)
EXTERNAL_IP=$(cat < /data/proxy_pipe)
sleep 4 && ./mtproto-proxy -u root -p 2398 -H 4430 -S $USER_SECRET --nat-info $INTERNAL_IP:$EXTERNAL_IP --allow-skip-dh --aes-pwd proxy-secret proxy-multi.conf -M 1
