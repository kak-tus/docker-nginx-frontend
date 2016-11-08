max_stale = "2m"

deduplicate {
  enabled = true
  prefix = "service/consul-template/dedup/"
}

template {
  source = "/root/services.conf.template"
  destination = "/etc/nginx/conf.d/services.conf"
  perms = 0700
}

exec {
  command = "nginx -g 'daemon off;'"
  splay = "60s"
  reload_signal = "SIGHUP"
}
