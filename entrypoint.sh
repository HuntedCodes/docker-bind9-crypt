#!/bin/sh

if [ -z $DNS_FORWARDER ]; then DNS_FORWARDER="none"; fi

if [ "$DNS_FORWARDER" = "dnscrypt" ]; then
  # DNSCrypt resolver list and config
  echo "[*] Updating DNSCrypt Resolver List"
  wget \
    -O /data/dnscrypt/dnscrypt-resolvers.csv \
    https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/dnscrypt-resolvers.csv
  chown dnscrypt /data/dnscrypt/dnscrypt-resolvers.csv
  chown dnscrypt /data/dnscrypt/dnscrypt-proxy.conf

  # Run DNSCrypt
  echo "[*] Starting DNSCrypt Proxy"
  /usr/sbin/dnscrypt-proxy /data/dnscrypt/dnscrypt-proxy.conf;
fi;

# Link DNSCrypt and BIND config
echo "[*] Forwarding DNS to: [$DNS_FORWARDER]"
ln -sf \
  "/data/bind/etc/forwarders/$DNS_FORWARDER" \
  "/data/bind/etc/forwarders/enabled_forwarder"

# Start BIND
echo "[*] Starting BIND Nameserver"
/usr/sbin/named -u bind -c /data/bind/etc/named.conf -f
