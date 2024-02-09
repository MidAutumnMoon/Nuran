{
    lib,
    vendorhash,
    buildGoModule,

    caddy,
}:

let

    plugins = [
        "github.com/caddy-dns/cloudflare"
    ];

    # main.go has following structure
    #
    # package main
    # import (
    #     cadyxx "xxx"
    #     _ "caddy/modules/standard"
    #  )
    #  main() { xxx }
    #
    # where the closing ")" of import is on its
    # own line, so prepending to that that line
    # is also adding things to import
    addPlugins = lib.concatStringsSep "\n" (
        lib.flip map plugins ( p: ''
            sed -i \
                '/^)$/i_ "${p}"' \
                "cmd/caddy/main.go"
        '' )
    );

    proxyBuilder = args: buildGoModule ( args // {
        GOAMD64 = "v3";
        CGO_ENABLED = false;
        proxyVendor = true;
        vendorHash = vendorhash."caddy";
        preBuild = ''
            ${addPlugins}
            go mod tidy -v
        '';
    } );

in

caddy.override { buildGoModule = proxyBuilder; }
