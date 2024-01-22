{
    sources,
    stdenvNoCC,
    caddy,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

    pname = "caddy";
    version = caddy.version;


    buildCommand = ''
        install -Dm755 \
            "${sources.${drvSelf.pname}.src}" \
            "$out/bin/${drvSelf.pname}"
    '';


    meta = {

        mainProgram = drvSelf.pname;

        caddyVer = "v${caddy.version}";

        caddyPlugins = [
            "github.com/caddy-dns/cloudflare"
        ];

        caddyBuildEnv = [ "GOAMD64=v3" ];

    };

} )
