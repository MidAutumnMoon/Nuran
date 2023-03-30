{ lib, config }:

let

  inherit ( config.nudata.services.dnscrypt )
    listen_addr listen_addr6;

in

''
server_names = [
  'cloudflare6',
  'quad9',
  'iij'
]

listen_addresses = [
  '${listen_addr}:53',
  '[${listen_addr6}]:53'
]

require_dnssec = true


timeout = 5000

keepalive = 60

lb_estimator = true


log_level = 2

use_syslog = true


bootstrap_resolvers = [ '223.5.5.5:53' ]

ignore_system_dns = true

netprobe_timeout = 60

netprobe_address = '223.5.5.5:53'

cache = true

cache_size = 4096



[query_log]

file = "/dev/stdout"

ignored_qtypes = [ 'DNSKEY', 'NS' ]


[sources]


[static.cloudflare6]
stamp = 'sdns://AgcAAAAAAAAAFlsyNjA2OjQ3MDA6NDcwMDo6MTAwMV0AEmRucy5jbG91ZGZsYXJlLmNvbQovZG5zLXF1ZXJ5'

[static.quad9]
stamp = 'sdns://AgcAAAAAAAAADVsyNjIwOmZlOjpmZV0ADWRucy5xdWFkOS5uZXQKL2Rucy1xdWVyeQ'

[static.iij]
stamp = 'sdns://AgcAAAAAAAAACjEwMy4yLjU3LjYAEXB1YmxpYy5kbnMuaWlqLmpwCi9kbnMtcXVlcnk'

# vim: ft=toml:

''
