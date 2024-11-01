# frozen_string_literal: true

packages = %w[
    caddy_teapot
    rust-analyzer_teapot
    shadowsocks_teapot
    zhudou-sans

    fishPlugins.tide
]

packages << {
    attr: "fishPlugins.puffer-fish",
    unstable: true,
}

packages << {
    attr: "hysteria_teapot",
    regex: %r{app/v(.*)},
}

packages
