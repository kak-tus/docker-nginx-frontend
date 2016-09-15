FROM nginx:1.10.1

ENV CONSUL_HTTP_ADDR=

COPY services.conf.template /etc/nginx/conf.d/services.conf.template
COPY consul-template_0.15.0_SHA256SUMS /usr/local/bin/consul-template_0.15.0_SHA256SUMS
COPY all_services.pl /usr/local/bin/all_services.pl

RUN rm /etc/nginx/conf.d/default.conf \

  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip libcommon-sense-perl libwww-perl libcpanel-json-xs-perl \
  liblist-moreutils-perl \

  && cd /usr/local/bin \

  && curl -L https://releases.hashicorp.com/consul-template/0.15.0/consul-template_0.15.0_linux_amd64.zip -o consul-template_0.15.0_linux_amd64.zip \
  && sha256sum -c consul-template_0.15.0_SHA256SUMS \
  && unzip consul-template_0.15.0_linux_amd64.zip \
  && rm consul-template_0.15.0_linux_amd64.zip consul-template_0.15.0_SHA256SUMS

CMD consul-template -once -template="/etc/nginx/conf.d/services.conf.template:/etc/nginx/conf.d/services.conf" ; nginx -g 'daemon off;'
