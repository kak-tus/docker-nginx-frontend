#!/usr/bin/env sh

/usr/local/bin/consul-template -once -template "/root/resolve_services.conf.template:/etc/resolve/services.conf"

if [ "$?" != "0" ]; then
  exit
fi

/usr/local/bin/resolve.sh once

/usr/local/bin/resolve.sh &
child1=$!

/usr/local/bin/consul-template -config /root/nginx.hcl &
child2=$!

trap "kill $child1 ; kill $child2" SIGTERM SIGINT

while true; do
  kill -0 "$child1"
  if [ "$?" = "0" ]; then
    sleep 5
  else
    echo "Exited resolve"
    exit
  fi

  kill -0 "$child2"
  if [ "$?" = "0" ]; then
    sleep 5
  else
    echo "Exited nginx"
    exit
  fi
done
