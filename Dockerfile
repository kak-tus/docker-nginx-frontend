FROM nginx:1.10.1

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

ENV VAULT_PATH=secret/certificates

COPY services.conf.template /root/services.conf.template
COPY consul-template_0.16.0_SHA256SUMS /usr/local/bin/consul-template_0.16.0_SHA256SUMS
COPY skip.sh /usr/local/bin/skip.sh
COPY get_certificates.hcl.template /root/get_certificates.hcl.template
COPY get_certificates.sh.template /root/get_certificates.sh.template
COPY fullchain.pem.template /root/fullchain.pem.template
COPY fullchain_renew.pem.template /root/fullchain_renew.pem.template
COPY key.pem.template /root/key.pem.template
COPY key_renew.pem.template /root/key_renew.pem.template
COPY renew.hcl.template /root/renew.hcl.template
COPY renew_certificates.hcl.template /root/renew_certificates.hcl.template
COPY dhparams.pem.template /root/dhparams.pem.template
COPY fullchain_renew.pem.template /root/fullchain_renew.pem.template

RUN rm /etc/nginx/conf.d/default.conf \
  && mkdir -p /etc/nginx/certificates \

  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip \

  && cd /usr/local/bin \

  && curl -L https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -o consul-template_0.16.0_linux_amd64.zip \
  && sha256sum -c consul-template_0.16.0_SHA256SUMS \
  && unzip consul-template_0.16.0_linux_amd64.zip \
  && rm consul-template_0.16.0_linux_amd64.zip consul-template_0.16.0_SHA256SUMS \

  && apt-get remove -y curl unzip && rm -rf /var/lib/apt/lists/*

CMD consul-template -config /root/get_certificates.hcl.template
