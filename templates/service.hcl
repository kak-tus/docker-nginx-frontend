max_stale = "2m"

log_level = "err"

template {
  source = "/root/templates/services.conf.template"
  destination = "/etc/nginx/conf.d/services.conf"
}

template {
  source = "/root/templates/cache.flag.template"
  destination = "/etc/nginx/cache.flag"
  command = "find /var/lib/nginx/cache -type f -delete"
}

template {
  source = "/root/templates/stream.conf.template"
  destination = "/etc/nginx/stream.conf"
}

template {
  source = "/root/templates/nginx.conf.template"
  destination = "/etc/nginx/nginx.conf"
}

template {
  source = "/root/templates/ext.conf.template"
  destination = "/etc/nginx/conf.d/ext.conf"
}

exec {
  command = "nginx -g 'daemon off;'"
  splay = "10s"
  reload_signal = "SIGHUP"
  kill_signal = "SIGQUIT"
}
