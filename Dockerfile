FROM nginx:1.10.3-alpine

COPY consul-template_0.16.0_SHA256SUMS /usr/local/bin/consul-template_0.16.0_SHA256SUMS

RUN rm /etc/nginx/conf.d/default.conf \
  && mkdir -p /etc/nginx/certificates \
  && mkdir -p /var/lib/nginx/cache \

  && apk add --update-cache curl unzip \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -o consul-template_0.16.0_linux_amd64.zip \
  && sha256sum -c consul-template_0.16.0_SHA256SUMS \
  && unzip consul-template_0.16.0_linux_amd64.zip \
  && rm consul-template_0.16.0_linux_amd64.zip consul-template_0.16.0_SHA256SUMS \

  && apk del unzip \
  && rm -rf /var/cache/apk/*

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

ENV VAULT_PATH=secret/certificates

COPY services.conf.template /root/services.conf.template
COPY skip.sh /usr/local/bin/skip.sh
COPY nginx.hcl /root/nginx.hcl
COPY store.sh /usr/local/bin/store.sh
COPY cache.flag.template /root/cache.flag.template

CMD consul-template -config /root/nginx.hcl
