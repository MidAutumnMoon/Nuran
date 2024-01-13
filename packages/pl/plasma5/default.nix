{
    emptyDirectory,

    old,
}:

old.overrideScope ( _self: prev: {

    kwallet-pam =
        prev.kwallet-pam.overrideAttrs ( oldAttrs: {
            # In spirit of NixOS/nixpkgs/pull/220100
            patches = [ ./kwallet.patch ];
        } );

    kdeGear = prev.kdeGear.overrideScope ( _self: _prev: {
        elisa = emptyDirectory;
        kinfocenter = emptyDirectory;
        plasma-systemmonitor = emptyDirectory;
        print-manager = emptyDirectory;
        gwenview = emptyDirectory;
        khelpcenter = emptyDirectory;
        okular = emptyDirectory;
    } );

    plasma5 = prev.plasma5.overrideScope ( _self: _prev: {
        plasma-browser-integration = emptyDirectory;
    } );

} )
