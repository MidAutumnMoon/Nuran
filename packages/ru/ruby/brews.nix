{
    lib,
    ruby_teapot,

    liburing,
}:

let

    ruby = ruby_teapot.override {
        moreGemsConfig = {
            io-event = _: { buildInputs = [ liburing ]; };
        };
    };

    build = gemset:
        ruby.buildGems gemset
        |> lib.attrValues
        |> lib.filter lib.isDerivation
        |> map ( g: g.override { document = [ "ri" ]; } )
        |> ( gems: ruby.withPackages( _: gems ) )
    ;

in {

    brewed = build ./gemset.nix;

    for_dev = build ./gemset-dev.nix;

}
