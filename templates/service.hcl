max_stale = "2m"

log_level = "err"

template {
  source = "/root/templates/services.conf.template"
  destination = "/tmp/services.conf"
}

template {
  source = "/root/templates/cache.flag.template"
  destination = "/etc/nginx/cache.flag"
  command = "find /var/lib/nginx/cache -type f -delete"
}

template {
  source = "/root/templates/stream.conf.template"
  destination = "/tmp/stream.conf"
}

template {
  source = "/root/templates/nginx.conf.template"
  destination = "/etc/nginx/nginx.conf"
}
