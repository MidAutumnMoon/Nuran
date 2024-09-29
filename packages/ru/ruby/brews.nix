{
    lib,
    ruby_teapot,
    runCommand,

    liburing,
}:

let

    local_ruby = ruby_teapot.override {
        moreGemsConfig = {
            io-event = _: { buildInputs = [ liburing ]; };
        };
    };

    from_gemset = gemset:
        lib.filter lib.isDerivation (
            lib.attrValues ( local_ruby.buildGems gemset )
        );

    with_docs =
        map ( gem: gem.override { document = [ "ri" ]; } );

    with_package =
        gems: local_ruby.withPackages ( _: gems );

    build =
        gemset: with_package ( with_docs ( from_gemset gemset ) );

in {

    brewed = build ./gemset.nix;

    for_dev = build ./gemset-dev.nix;

}
