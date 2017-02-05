max_stale = "2m"

template {
  source = "/root/services.conf.template"
  destination = "/etc/nginx/conf.d/services.conf"
}

template {
  source = "/root/cache.flag.template"
  destination = "/etc/nginx/cache.flag"
  command = "find /var/lib/nginx/cache -type f -delete"
  wait = "1m"
}

template {
  source = "/root/stream.conf.template"
  destination = "/etc/nginx/stream.conf"
}

exec {
  command = "nginx -g 'daemon off;'"
  splay = "60s"
  reload_signal = "SIGHUP"
}
