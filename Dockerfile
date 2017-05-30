FROM debian:stretch
MAINTAINER Jack Sullivan

# Install packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      wget ca-certificates \
      procps dnsutils \
      bind9 \
      dnscrypt-proxy dnscrypt-proxy-plugins && \
    apt-get clean

# Copy init and blacklist script
COPY entrypoint.sh /data/entrypoint.sh
COPY blacklist_update.sh /data/blacklist_update.sh
RUN chmod +x /data/entrypoint.sh /data/blacklist_update.sh

# BIND
RUN ln -sf /data/bind/etc/named.conf /etc/bind/named.conf
RUN mkdir -p /var/run/named && chown bind:bind /var/run/named

# DNSCrypt user
RUN adduser --system --quiet \
  --home /data/dnscrypt --shell /bin/false --group \
  --disabled-password --disabled-login dnscrypt

EXPOSE 53/udp

ENTRYPOINT ["/data/entrypoint.sh"]
