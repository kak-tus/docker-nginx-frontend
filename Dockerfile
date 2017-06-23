FROM nginx:1.12.0-alpine

ENV CONSUL_TEMPLATE_VERSION=0.18.5
ENV CONSUL_TEMPLATE_SHA256=b0cd6e821d6150c9a0166681072c12e906ed549ef4588f73ed58c9d834295cd2

RUN \
  rm /etc/nginx/conf.d/default.conf \
  && mkdir -p /etc/nginx/certificates \
  && mkdir -p /var/lib/nginx/cache \

  && apk add --no-cache --virtual .build-deps \
    curl \
    unzip \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \

  && ( ( crontab -l ; echo '*/5 * * * * /usr/local/bin/resolve.sh' ) | crontab - ) \

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

CMD ["/usr/local/bin/start.sh"]
