FROM debian:stretch
MAINTAINER Jack Sullivan

# Install packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      bind9 \
      dnscrypt-proxy \
      dnscrypt-proxy-plugins && \
    apt-get clean

# Diagnostic packages
RUN apt-get install -y procps dnsutils

# Copy init script
COPY entrypoint.sh /data/entrypoint.sh
RUN chmod +x /data/entrypoint.sh

# BIND
RUN ln -sf /data/bind/etc/named.conf /etc/bind/named.conf
RUN mkdir -p /var/run/named && chown bind:bind /var/run/named

# DNSCrypt user
RUN adduser --system --quiet \
  --home /data/dnscrypt --shell /bin/false --group \
  --disabled-password --disabled-login dnscrypt

EXPOSE 53/udp

ENTRYPOINT ["/data/entrypoint.sh"]
