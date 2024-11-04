{
    lib,
    buildGoModule,
    fetchFromGitHub,
}:

let

    # Explain of The Dark Art
    #
    # caddy's "main.go" file looks like this:
    #
    #   package main
    #
    #   import (
    #       caddycmd "url..."
    #       _ "url"
    #   )
    #
    #   func main
    #
    # Upon closer observation, we can notice that the closing ")"
    # of "import" statment is on its own line, which means by prepending
    # to the closing ")", content can be placed right inside the "import" statment.
    #
    # This part is done by using some sed magics: '/<reg>/i<content>'
    #                                                     ^ this flag
    plugins = [
        "github.com/caddy-dns/cloudflare"
    ]
    |> map ( name: '' sed -i '/^)$/i_ "${name}"' "cmd/caddy/main.go" '' )
    |> lib.concatStringsSep "\n"
    ;

in

buildGoModule rec {

    pname = "caddy";
    version = "2.8.4";

    src = fetchFromGitHub {
        owner = "caddyserver";
        repo = "caddy";
        rev = "v${version}";
        hash = "sha256-CBfyqtWp3gYsYwaIxbfXO3AYaBiM7LutLC7uZgYXfkQ=";
    };

    vendorHash = "sha256-q3UAau4vv+/J2lH/3Xd4pSNzraCtdDP3zo2n0S0oICs=";
    proxyVendor = true;


    subPackages = [ "cmd/caddy" ];

    ldflags = [
        "-s" "-w"
        "-X github.com/caddyserver/caddy/v2.CustomVersion=${version}"
    ];

    # See https://github.com/caddyserver/caddy/blob/master/.goreleaser.yml
    tags = [
        "nobadger"
        "nomysql"
        "nopgx"
    ];

    preBuild = ''
        ${plugins}
        go mod tidy -v
    '';


    GOAMD64 = "v2";
    CGO_ENABLED = "0";


    meta = {
        homepage = "https://caddyserver.com";
        license = lib.licenses.asl20;
        mainProgram = "caddy";
    };

}
