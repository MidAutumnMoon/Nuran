{
    sources,

    old,
}:

old.overrideScope' ( self: _: let

    callPackage =
        self.newScope { inherit sources; };

in {

    tide =
        callPackage ./tide.nix {};

    puffer-fish =
        callPackage ./puffer-fish.nix {};

} )
