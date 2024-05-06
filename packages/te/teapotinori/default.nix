{
    lib,
    newScope,

    pkgs,
}:

lib.makeScope newScope ( self: let

    generic = self.callPackage ./generic.nix {};

in {

    all = with self; [
        # derputils
        latoori
        rpgdemake
    ];

    # derputils = generic {
    #     pname = "derputils";
    #     buildInputs = [ pkgs.SDL2 ];
    # };

    latoori = generic {
        pname = "latoori";
        static = true;
    };

    rpgdemake = generic {
        pname = "rpgdemake";
    };

} )

