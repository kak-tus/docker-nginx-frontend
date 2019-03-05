FROM alpine:3.7 AS build

ENV \
  CONSUL_TEMPLATE_VERSION=0.19.4 \
  CONSUL_TEMPLATE_SHA256=5f70a7fb626ea8c332487c491924e0a2d594637de709e5b430ecffc83088abc0

RUN \
  apk add --no-cache \
    curl \
    unzip \
  \
  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

FROM nginx:1.15.8-alpine

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

COPY --from=build /usr/local/bin/consul-template /usr/local/bin/consul-template
COPY store.sh /usr/local/bin/store.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY templates /root/templates

CMD ["/usr/local/bin/entrypoint.sh"]
