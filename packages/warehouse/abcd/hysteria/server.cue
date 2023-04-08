listen: ":@hy_port@"

protocol: "udp"

obfs: "@hy_obfs@",

auth: {
    mode: "passwords",
    config: [ "@hy_auth@" ]
},

alpn: "h3"

cert: "@hy_cert@"
key: "@hy_key@"

resolver: "udp://@dns_addr@:53"
