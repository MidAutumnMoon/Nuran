{
    lib,
    ruby_teapot,

    liburing,
}:

let

    withDocs = map (
        g: g.override { document = [ "ri" ]; }
    );

    moreGems = lib.filter lib.isDerivation (
        lib.attrValues ( ruby.buildGems ( import ./gemset.nix ) )
    );

    moreGemsConfig = {
        io-event = attrs: { buildInputs = [ liburing ]; };
    };

    ruby = ruby_teapot.override {
        inherit moreGemsConfig;
    };

in

ruby.withPackages ( p: with p;
    withDocs ( [ rake rubocop ] ++ moreGems )
)
