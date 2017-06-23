#!/usr/bin/env sh

touch /etc/nginx/conf.d/services.conf
touch /etc/nginx/stream.conf

/usr/local/bin/resolve.sh

crond -f &
child1=$!

nginx -g 'daemon off;' &
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
