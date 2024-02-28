{
    lib,
    ruby_teapot,
}:

let

    ruby = ruby_teapot;

    withDocs = map (
        g: g.override { document = [ "ri" ]; }
    );

    moreGems = lib.filter lib.isDerivation (
        lib.attrValues ( ruby.buildGems ( import ./gemset.nix ) )
    );

in

ruby.withPackages ( p: with p;
    withDocs ( [ rake rubocop ] ++ moreGems )
)
