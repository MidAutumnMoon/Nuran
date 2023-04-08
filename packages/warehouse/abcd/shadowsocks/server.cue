dns: "@dns_addr@"

log: {
    level: 1
}

servers: [
    {
        address: "::"
        method: "2022-blake3-chacha20-poly1305"
        password: "@ss_password@"
        port: @ss_port_a@
    },
    {
        address: "::"
        method: "2022-blake3-aes-256-gcm"
        password: "@ss_password@"
        port: @ss_port_b@
    }
]

mode: "tcp_and_udp"

no_delay: true

runtime: {
    mode: "multi_thread"
}

