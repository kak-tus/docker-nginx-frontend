#!/usr/bin/env sh

mkdir -p /tmp/resolve

while true; do

  while read -r line; do
    name="$line"

    if [ -n "$name" ]; then
      ip=$( drill "$name" | fgrep IN | fgrep -v ';' | awk '{print $5}' | grep -E -o '^[0-9\.]+$' )

      if [ -n "$ip" ]; then
        echo -n $name > "/tmp/resolve/$name"
      else
        echo -n '127.0.0.1' > "/tmp/resolve/$name"
      fi
    fi
  done < "/etc/resolve/services.conf"

  if [ -n "$1" ]; then
    exit 0
  fi

  sleep 60
done
