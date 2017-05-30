## Forwarders

DNS forwarders and be specified at runtime using the `DNS_FORWARDERS`
environment variable. The `entrypoint.sh` script defaults to `none`, and the
`docker-compose.yml` file defaults to `dnscrypt`. You can find and add
forwarders in the BIND configuration `forwarders/` subdirectory.

If the value is set to `dnscrypt`, an instance of `dnscrypt-proxy` is started,
and all queries to BIND will be forwarded to the configured encrypted resolver.

If the value is set to `none`, then no forwarder will be used, and all queries
will be recursively solved with root nameservers.


## The Blackhole and Blacklists

The `DNS_BLACKHOLE` environment variable, passed to Docker at runtime,
specifies the IP address to return for blacklisted domains. Popular blackhole
IP addresses include [127.0.0.1](https://en.wikipedia.org/wiki/Localhost)
and [0.0.0.0](https://en.wikipedia.org/wiki/0.0.0.0). It can also be set to
some other host you designate for analysis or notification purposes.

Advertising and malicious host blacklists are gathered, collated, and
de-dupicated from the following sources:

- https://hosts-file.net/ad_servers.txt
- https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
- https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
- https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
- https://mirror1.malwaredomains.com/files/justdomains
- http://sysctl.org/cameleon/hosts
