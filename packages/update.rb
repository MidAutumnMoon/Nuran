# frozen_string_literal: true

packages = %w[
    hysteria_teapot
    rust-analyzer_teapot
    shadowsocks_teapot
    zhudou-sans
    fishPlugins.tide
]

packages << {
    attr: "fishPlugins.puffer-fish",
    branch: true,
}

packages
