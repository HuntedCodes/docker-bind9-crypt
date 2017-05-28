#!/bin/sh

# Ensure presence.
#mkdir -p /data/bind/run

# Ensure permissions.
#chown root:root /data/bind/etc/* 

# Start the bind.
/usr/sbin/named -u bind -c /data/bind/etc/named.conf -g
