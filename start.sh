#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo "$CONTAINER_TIMEZONE" > /etc/timezone \
    && ln -sf "/usr/share/zoneinfo/$CONTAINER_TIMEZONE" /etc/localtime
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

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
