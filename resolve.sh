#!/usr/bin/env sh

/usr/local/bin/consul-template -config /root/nginx.hcl -once

if [ "$?" != "0" ]; then
  exit
fi

changed="0"

diff=`diff /tmp/services.conf /etc/nginx/conf.d/services.conf`

if [ -n "$diff" ]; then
  echo "services changed"
  changed="1"
  cp /tmp/services.conf /etc/nginx/conf.d/services.conf
fi

diff=`diff /tmp/stream.conf /etc/nginx/stream.conf`

if [ -n "$diff" ]; then
  echo "stream changed"
  changed="1"
  cp /tmp/stream.conf /etc/nginx/stream.conf
fi

if [ "$changed" = "1" ]; then
  nginx -s reload
fi
