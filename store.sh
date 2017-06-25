#!/usr/bin/env sh

dir=$(dirname $1)
mkdir -p $dir

echo "$2" > "$1.tmp"

touch "$1"
diff=$(diff "$1" "$1.tmp")

if [ -n "$diff" ]; then
  mv "$1.tmp" "$1"
  chmod 600 "$1"

  nginx -s reload
else
  rm "$1.tmp"
fi

exit 0
