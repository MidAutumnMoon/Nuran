{ emptyDirectory }:

plasmaSelf: plasmaSuper: {

  kwallet-pam =
    plasmaSuper.kwallet-pam.overrideAttrs ( oldAttrs: {
      patches = [ ./temporary.patch ];
    } );

  kdeGear = plasmaSuper.kdeGear.overrideScope' ( gearSelf: gearSuper: {
      elisa = emptyDirectory;
      kinfocenter = emptyDirectory;
      plasma-systemmonitor = emptyDirectory;
      print-manager = emptyDirectory;
      gwenview = emptyDirectory;
      khelpcenter = emptyDirectory;
      okular = gearSuper.okular.override { withSpeech = false; };
    } );

  plasma5 = plasmaSuper.plasma5.overrideScope' ( plasmaSelf: plasmaSuper: {
      plasma-browser-integration = emptyDirectory;
    } );

}
