#!/usr/bin/env sh

/usr/local/bin/consul-template -once -template "/root/resolve_services.conf.template:/etc/resolve/services.conf"
/usr/local/bin/resolve.sh once

/usr/local/bin/resolve.sh &
child1=$!

/usr/local/bin/consul-template -config /root/nginx.hcl &
child2=$!

trap "kill $child1 ; kill $child2" SIGTERM
wait "$child1"
wait "$child2"
