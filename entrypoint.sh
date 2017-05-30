#!/bin/sh

LOG_DIR="/data/bind/log";
if [ ! -d "$LOG_DIR" ]; then mkdir -p $LOG_DIR && chown bind $LOG_DIR; fi

if [ -z $DNS_FORWARDER ]; then DNS_FORWARDER="none"; fi
if [ -z $DNS_BLACKHOLE ]; then DNS_BLACKHOLE="null"; fi

# DNSCrypt config
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

# Update yoyo DNS blacklist
echo "[*] Updating yoyo DNS blacklist"
YOYO_FILE="/data/bind/etc/blacklists/yoyo"
wget -O- \
  "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=bindconfig&showintro=0&mimetype=plaintext" \
  | sed -r 's/null\.zone\.file/\/data\/bind\/etc\/zones\/blackhole/g' > $YOYO_FILE

# Link forwarder
echo "[*] Forwarding DNS to: [$DNS_FORWARDER]"
ln -sf \
  "/data/bind/etc/forwarders/$DNS_FORWARDER" \
  "/data/bind/etc/enabled_forwarder"

# Configure blackhole zone
echo "[*] Blackhole to: [$DNS_BLACKHOLE]"
cat "/data/bind/etc/zones/blackhole_template" | sed -r "s/XXXXXXXX/$DNS_BLACKHOLE/g" > "/data/bind/etc/zones/blackhole"

# Permissions
chown -R bind /data/bind/etc
chmod 775 /data/bind/etc

chown -R bind /data/bind/etc/blacklists
chmod 775 /data/bind/etc/blacklists
chmod 664 /data/bind/etc/blacklists/*

chown -R bind /data/bind/etc/forwarders
chmod 775 /data/bind/etc/forwarders
chmod 664 /data/bind/etc/forwarders/*

chown -R bind /data/bind/etc/zones
chmod 775 /data/bind/etc/zones
chmod 664 /data/bind/etc/zones/*

chmod 775 /data/bind/log

# Start BIND
echo "[*] Starting BIND Nameserver"
/usr/sbin/named -u bind -c /data/bind/etc/named.conf -4
tail -f /data/bind/log/default.log
