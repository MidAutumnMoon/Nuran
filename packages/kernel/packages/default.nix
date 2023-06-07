{
    kernel,

    linuxPackagesFor,
}:

( linuxPackagesFor kernel ).extend ( self: super: {

    nvidiaPackages = super.nvidiaPackages.extend ( nvSelf: nvSuper: {
        stable = nvSuper.stable.override { disable32Bit = true; };
    } );

} )
