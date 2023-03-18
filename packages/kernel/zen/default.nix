{
  callPackage,
  linuxPackagesFor,
}:

let

  zenPackage =
    linuxPackagesFor ( callPackage ./kernel.nix {} );

in

zenPackage.extend ( self: super: {

  nvidiaPackages = super.nvidiaPackages.extend ( nvidiaSelf: nvidiaSuper: {
      stable =
        nvidiaSuper.stable.override { disable32Bit = true; };
    } );

} )
