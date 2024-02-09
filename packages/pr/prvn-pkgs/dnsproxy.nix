{
    sources,
    vendorhash,

    upx-pack,

    stdenv,
    buildGoModule,
    fetchFromGitHub,
}:

let

    dd = buildGoModule rec {
        pname = "dnsproxy";
        version = "0.64.1";

        src = fetchFromGitHub {
            owner = "AdguardTeam";
            repo = pname;
            rev = "v${version}";
            sha256 = "sha256-w5eGMf6noQh8K2TlHmT7Qj/pU96J3Y1qrn4inrQ2FL4=";
        };

        vendorHash = vendorhash."prvn-pkgs.dnsproxy";
        proxyVendor = true;

        ldflags = let
            v = "github.com/AdguardTeam/dnsproxy/internal/version";
        in [
            "-s" "-w"
            "-X" "main.VersionString=${version}"
            "-X" "${v}.version=${version}"
        ];

        doCheck = false;
        CGO_ENABLED = 0;

        subPackages = [ "." ];

      # meta = with lib; {
      #   description = "Simple DNS proxy with DoH, DoT, and DNSCrypt support";
      #   homepage = "https://github.com/AdguardTeam/dnsproxy";
      #   license = licenses.asl20;
      #   maintainers = with maintainers; [ contrun ];
      # };
    };

in

dd

# stdenv.mkDerivation ( drvSelf: {
#
#     name = "dnsproxy";
#
#     inherit ( sources.${drvSelf.name} )
#         src
#     ;
#
#     nativeBuildInputs = [ upx-pack ];
#
#     installPhase = ''
#         mkdir -p "$out/bin"
#         upx-pack "dnsproxy" "$out/bin/dnsproxy"
#     '';
#
# } )
