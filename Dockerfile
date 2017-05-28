FROM debian
MAINTAINER Jack Sullivan

# Install squid-deb-proxy
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
      bind9 && \
    apt-get clean

# Copy init script
COPY entrypoint.sh /data/entrypoint.sh
RUN chmod +x /data/entrypoint.sh

# Links and paths
RUN ln -sf /data/bind/etc/named.conf /etc/bind/named.conf
RUN mkdir -p /var/run/named && chown bind:bind /var/run/named

EXPOSE 53/udp

ENTRYPOINT ["/data/entrypoint.sh"]
