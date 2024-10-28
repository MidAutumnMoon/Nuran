{
    old,
}:

old.overrideScope ( self: _: {

    tide =
        self.callPackage ./tide.nix {};

    puffer-fish =
        self.callPackage ./puffer-fish.nix {};

} )
