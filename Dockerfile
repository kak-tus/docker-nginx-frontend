FROM hashicorp/consul-template:0.27.2 as consul-template

FROM nginx:1.21.5-alpine

RUN \
  apk add --no-cache \
    ca-certificates \
  \
  && rm /etc/nginx/conf.d/default.conf \
  && mkdir -p /etc/nginx/certificates \
  && mkdir -p /var/lib/nginx/cache

ENV \
  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \
  VAULT_ADDR= \
  VAULT_TOKEN= \
  \
  SET_CONTAINER_TIMEZONE=true \
  CONTAINER_TIMEZONE=Europe/Moscow \
  \
  NGINX_EXT_KEY=config/nginx/extended \
  NGINX_SERVICES_FILTER= \
  NGINX_VAULT_PATH=secret/certificates \
  NGINX_WORKER_CONNECTIONS=1024 \
  NGINX_WORKER_PROCESSES=1

COPY --from=consul-template /bin/consul-template /usr/local/bin/consul-template
COPY store.sh /usr/local/bin/store.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY templates /root/templates

CMD ["/usr/local/bin/entrypoint.sh"]
