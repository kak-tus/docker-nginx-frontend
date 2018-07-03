#!/usr/bin/env sh

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo "$CONTAINER_TIMEZONE" > /etc/timezone \
    && ln -sf "/usr/share/zoneinfo/$CONTAINER_TIMEZONE" /etc/localtime
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

/usr/local/bin/consul-template -config /root/templates/service.hcl &
child=$!

trap "kill $child" SIGTERM SIGINT
wait $child
trap - SIGTERM SIGINT
wait $child
