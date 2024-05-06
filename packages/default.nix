{ lib }:

final: prev:

let

    sources =
        final.callPackage ./__sources/generated.nix {};

    vendorhash =
        final.callPackage ./__vendorhash { inherit lib; };

    callPackage = final.newScope {
        inherit lib sources callPackage vendorhash;
    };

in

rec {

    /*
     * Put these above all sections because
     * I would forget this things otheriwse.
     */

    inherit sources vendorhash;

    nuranScripts = callPackage ./__tools {};

    /*
     * Web facing services and other network
     * related things.
     */

    caddy_teapot =
        callPackage ./ca/caddy {};

    hentai-home =
        callPackage ./he/henati-home {};

    nginx_teapot =
        callPackage ./ng/nginx {};

    shadowsocks_teapot =
        callPackage ./sh/shadowsocks {};

    hysteria_teapot =
        callPackage ./hy/hysteria {};

    /*
     * Terminals, shells and other things used in
     * that environment like CLI/TUI tools or multiplexers.
     *
     * Basically everything in Linux uh?
     */

    teapotinori =
        callPackage ./te/teapotinori {};

    fishPlugins =
        callPackage ./fi/fish/plugins { old = prev.fishPlugins; };

    neovim_teapot =
        callPackage ./ne/neovim {};

    prime-offload =
        callPackage ./pr/prime-offload {};

    /*
     * Desktop, GUI, graohics etc. things.
     *
     * Does terminal emulator belongs to this
     * category or the previous one? Hmmm...
     */

    firefox_teapot =
        callPackage ./fi/firefox {};

    gtkgreet_teapot =
        callPackage ./gt/gtkgreet {};

    /*
     * Linux kernel and modules and packages for it.
     */

    linux_teapot =
        callPackage ./ke/kernel/vanilla {};

    linuxPackages_teapot =
        callPackage ./ke/kernel/packages { kernel = linux_teapot; };

    /*
     * Themes, colors, fonts, styles, etc.
     * colorful and fancy things.
     */

    graphite-cursor-theme =
        callPackage ./gr/graphite-cursor-theme {};

    ibm-plex_teapot =
        callPackage ./ib/ibm-plex {};

    iosevka_teapot =
        callPackage ./io/iosevka {};

    zhudou-sans =
        callPackage ./zh/zhudou-sans {};

    /*
     * Services-ish things, which are neither used
     * in command line nor have a GUI.
     */

    k380-fn-keys-swap =
        callPackage ./k3/k380-fn-keys-swap {};

    /*
     * Languages and their toolchinas>
     */

    ruby_teapot =
        callPackage ./ru/ruby {};

    /*
     * Things that no clear category they are
     * falling into.
     */

     prvn-pkgs =
        callPackage ./pr/prvn-pkgs {};

    /*
     * Optimization flags. Mostly unused.
     */

    teapot.march = "x86-64-v3";

    teapot.mtune = "znver2";

    teapot.optimiz = [
        "-O3"
        "-march=${teapot.march}"
        "-mtune=${teapot.mtune}"
        "-mpclmul"
        "-pipe"
    ];

    teapot.RUSTFLAGS = [
        "-Ctarget-cpu=${teapot.march}"
    ];


    /*
     * Whatever the thing is.
     */

    stdenvTeapot =
        with prev.buildPackages.llvmPackages_18;
        prev.overrideCC stdenv ( libstdcxxClang.override {
            inherit bintools;
        } );

    # "mkDerivationFromStdenv" is a function which accepts a stdenv
    # as argument and returns the well-known "mkDerivation" function,
    # the default and probably only impl is make-derivation.nix
    #
    # By wrapping "mkDerivationFromStdenv" any derivation can
    # be modified using a custom $functor just before being given birth.
    #
    # $functor is used to overrideAttrs on derivations
    # $stdenv is some normal stdenv, don't forget this function is
    #         a mimic of "mkDerivationFromStdenv" whose
    #         argument is stdenv
    # $mkDrvArgs: after accepting $stdenv the result is just
    #             a "mkDerivation" function, this is its argument
    defaultMkDrvImpl = with final;
        import "${path}/pkgs/stdenv/generic/make-derivation.nix" {
            inherit lib config;
        };

    overridableMkDrvImpl = mkDrvImpl: functor:
        ( stdenv: mkDrvArgs:
          ( ( mkDrvImpl stdenv ) mkDrvArgs ).overrideAttrs functor
        );

    overrideAttrsOnAllDrv = stdenv: functor:
        stdenv.override ( oldArgs: {
            mkDerivationFromStdenv = overridableMkDrvImpl
                ( oldArgs.mkDerivationFromStdenv or defaultMkDrvImpl )
                functor;
        } );

    # demo
    useLLDLinker = stdenv:
        overrideAttrsOnAllDrv stdenv ( drvAttrs: {
            NIX_CFLAGS_LINK =
                toString ( drvAttrs.NIX_CFLAGS_LINK or "" )
                + " -fuse-ld=lld";
        } );

}
