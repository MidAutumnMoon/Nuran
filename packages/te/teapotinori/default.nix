{
    lib,
    newScope,

    pkgs,
}:

lib.makeScope newScope ( self: let

    generic = self.callPackage ./generic.nix {};

in {

    all = with self; [
        derputils
    ];

    derputils = generic {
        pname = "derputils";
        buildInputs = [ pkgs.SDL2 ];
    };

} )

