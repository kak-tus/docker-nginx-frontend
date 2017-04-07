FROM nginx:1.10.3-alpine

ENV CONSUL_TEMPLATE_VERSION=0.18.2
ENV CONSUL_TEMPLATE_SHA256=6fee6ab68108298b5c10e01357ea2a8e4821302df1ff9dd70dd9896b5c37217c

RUN \
  rm /etc/nginx/conf.d/default.conf \
  && mkdir -p /etc/nginx/certificates \
  && mkdir -p /var/lib/nginx/cache \

  && apk add --no-cache drill \

  && apk add --no-cache --virtual .build-deps curl unzip \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && apk del .build-deps

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

ENV VAULT_PATH=secret/certificates

COPY services.conf.template /root/services.conf.template
COPY nginx.hcl /root/nginx.hcl
COPY store.sh /usr/local/bin/store.sh
COPY cache.flag.template /root/cache.flag.template
COPY nginx.conf /etc/nginx/nginx.conf
COPY stream.conf.template /root/stream.conf.template
COPY resolve.sh /usr/local/bin/resolve.sh
COPY start.sh /usr/local/bin/start.sh
COPY resolve_services.conf.template /root/resolve_services.conf.template

CMD [ "/usr/local/bin/start.sh" ]
