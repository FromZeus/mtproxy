#!/bin/sh

curl -s https://core.telegram.org/getProxySecret -o proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

if [ ! -f /data/proxy_pipe ]; then
  mkfifo /data/proxy_pipe
fi

if [ ! -z "$USER_SECRET" ]; then
  echo "[+] Using the explicitly passed user secret: $USER_SECRET"
elif [ -f /data/user_secret ]; then
  echo "[+] Using previously generated secret: $USER_SECRET"
  USER_SECRET="$(cat /data/user_secret)"
else
  USER_SECRET="$(head -c 16 /dev/urandom | xxd -p)"
  echo "[+] Using randomly generated secret: $USER_SECRET"
fi
echo $USER_SECRET > /data/proxy_pipe
echo $USER_SECRET > /data/user_secret

if [ ! -z "$INTERNAL_IP" ]; then
  echo "[+] Using the explicitly passed internal IP: $INTERNAL_IP"
else
  INTERNAL_IP="$(ip -4 route get 8.8.8.8 | grep '^8\.8\.8\.8\s' | grep -Eo 'src\s+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}')"
  if [[ -z "$INTERNAL_IP" ]]; then
    echo "[F] Cannot determine internal IP address."
    exit 4
  else
    echo "[+] Using the detected internal IP: ${INTERNAL_IP}."
  fi
fi
echo $INTERNAL_IP > /data/proxy_pipe

if [ ! -z "$EXTERNAL_IP" ]; then
  echo "[+] Using the explicitly passed external IP: $EXTERNAL_IP"
else
  EXTERNAL_IP="$(curl -s -4 "https://digitalresistance.dog/myIp")"
  if [[ -z "$EXTERNAL_IP" ]]; then
    echo "[F] Cannot determine external IP address."
    exit 3
  else
    echo "[+] Using the detected external IP: ${EXTERNAL_IP}."
  fi
fi
echo $EXTERNAL_IP > /data/proxy_pipe
