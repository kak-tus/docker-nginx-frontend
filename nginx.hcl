max_stale = "2m"

template {
  source = "/root/services.conf.template"
  destination = "/tmp/services.conf"
}

template {
  source = "/root/cache.flag.template"
  destination = "/etc/nginx/cache.flag"
  command = "find /var/lib/nginx/cache -type f -delete"
}

template {
  source = "/root/stream.conf.template"
  destination = "/tmp/stream.conf"
}
