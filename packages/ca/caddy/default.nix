{
    stdenvNoCC,

    caddy,
}:

let


in

stdenvNoCC.mkDerivation {

    pname = "caddy";
    version = caddy.version;


    meta = {

        caddyVer = "v${caddy.version}";

        caddyPlugins = [
            "github.com/caddy-dns/cloudflare"
        ];

        caddyBuildEnv = [ "GOAMD64=v3" ];

    };

}
