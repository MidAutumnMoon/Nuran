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
        rpgdemake
    ];

    derputils = generic {
        pname = "derputils";
    };

    rpgdemake = generic {
        pname = "rpgdemake";
    };

} )

