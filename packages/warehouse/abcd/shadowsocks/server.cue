dns: "@dns_addr@"

log: {
    level: 1
}

servers: [
    {
        address: "::"
        method: "2022-blake3-aes-256-gcm"
        password: "@ss_password@"
        port: @ss_port_a@
    }
]

mode: "tcp_and_udp"

no_delay: true

runtime: {
    mode: "multi_thread"
}

// outbound_bind_interface: "wgcf"
