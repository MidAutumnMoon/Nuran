{
    lib,
    ruby_teapot,

    liburing,
}:

let

    moreGemsConfig = {
        io-event = _: { buildInputs = [ liburing ]; };
    };

    ruby = ruby_teapot.override {
        inherit moreGemsConfig;
    };

    moreGems = lib.filter lib.isDerivation (
        lib.attrValues ( ruby.buildGems ./gemset.nix )
    );

in

ruby.withPackages ( _:
    map ( g: g.override { document = [ "ri" ]; } ) moreGems
)
