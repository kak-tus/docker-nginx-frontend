max_stale = "2m"

template {
  source = "/root/services.conf.template"
  destination = "/etc/nginx/conf.d/services.conf"
}

exec {
  command = "nginx -g 'daemon off;'"
  splay = "60s"
  reload_signal = "SIGHUP"
}
