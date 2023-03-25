{ lib }:

final: prev:

let

  sources =
    final.callPackage ./_sources/generated.nix {};

  callPackage =
    final.newScope { inherit lib sources callPackage; };

in

rec {


  /*
  *
  * Things lossely categorized into "Network"
  *
  */

  firefox_teapot =
    callPackage ./network/firefox {};

  shadowsocks_teapot =
    callPackage ./network/shadowsocks-rust {};

  nginx_teapot =
    callPackage ./network/nginx {};

  hentai-home =
    callPackage ./network/henati-home {};



  /*
  *
  * Text etc. "Editor"
  *
  */

  neovim_teapot =
    callPackage ./editor/neovim/wrapped.nix {};



  /*
  *
  * Tools to work with some "Language"
  *
  */

  luajit_teapot =
    callPackage ./language/lua/luajit { self = luajit_teapot; };

  inherit ( luajit_teapot.pkgs ) moonscript;



  /*
  *
  * "Utility"s are useful things without categorizing
  *
  */

  derputils =
    callPackage ./utility/derputils {};

  prime-offload =
    callPackage ./utility/prime-offload {};

  k380-fn-keys-swap =
    callPackage ./utility/k380-fn-keys-swap {};



  /*
  *
  * "Terminal" & "Shell"
  *
  */

  fishPlugins =
    prev.fishPlugins.overrideScope' ( callPackage ./shterm/fish-plugin {} );



  /*
  *
  * Watch videos / play games for "Entertain"
  *
  */

  mpv_teapot =
    callPackage ./entertain/mpv {};

  yuzu_teapot =
    prev.libsForQt5.callPackage ./entertain/yuzu { inherit sources; };



  /*
  *
  * Suppose these are related to "Kernel"
  *
  */

  linuxPackages_teapot =
    callPackage ./kernel/zen {};



  /*
  *
  * "Theme" / "Color" and "Font"
  *
  */

  graphite-cursor-theme =
    callPackage ./theme/cursors/graphite-cursor-theme {};

  iosevka_teapot =
    callPackage ./font/iosevka {};

  noto-fonts-cjk_teapot =
    callPackage ./font/noto-fonts-cjk {};

  nerdfonts_teapot =
    callPackage ./font/nerd-fonts {};



  /*
  *
  * Things not willing to be categorized
  *
  */

  plasma5Packages =
    prev.plasma5Packages.overrideScope' ( callPackage ./warehouse/plasma5 {} );

  mdbook-catppuccin =
    callPackage ./warehouse/mdbook/catppuccin {};

  mdbook-toc =
    callPackage ./warehouse/mdbook/toc {};



  /*
  *
  * Hopefully useful "Flags"
  *
  */

  teapot.march = "x86-64-v3";

  teapot.mtune = "znver2";

  teapot.baseOptimiz = [
      "-march=${ teapot.march }"
      "-mtune=${ teapot.mtune }"
      "-fno-semantic-interposition"
      "-fomit-frame-pointer"
      "-pipe"
    ];

  teapot.aggressiveOptimiz =
    teapot.baseOptimiz ++ [
      "-O3"
      "-fno-math-errno"
      "-fno-trapping-math"
      "-fno-signed-zeros"
      "-fassociative-math"
      "-freciprocal-math"
    ];

  teapot.RUSTFLAGS = [
      "-C target-cpu=${ teapot.march }"
      "-C linker=clang"
      "-C link-arg=-fuse-ld=mold"
    ];



  /*
  *
  * Play dark arts with nixpkgs' "Stdenv"
  *
  */

  # stdenvTeapot =
  #   with prev.buildPackages.llvmPackages_15;
  #   prev.overrideCC stdenv ( libstdcxxClang.override { inherit bintools; } );

  stdenvTeapot =
    with prev;
    useMoldLinker buildPackages.llvmPackages_15.stdenv;

  rustPlatformTeapot =
    with prev;
    makeRustPlatform ( rustPackages // { stdenv = stdenvTeapot; } );


  # "mkDerivationFromStdenv" is a function which accepts a stdenv
  # as argument and returns the well-known "mkDerivation" function,
  # the default and probably only impl is make-derivation.nix
  #
  # By wrapping "mkDerivationFromStdenv" any derivation can
  # be modified using a custom $functor just before being given birth.
  #
  # $functor is used to overrideAttrs on derivations
  # $stdenv is some normal stdenv, don't forget this function is
  #         a mimic of "mkDerivationFromStdenv" whose argument is stdenv
  # $mkDrvArgs: after accepting $stdenv the result is just
  #             a "mkDerivation" function, this is its argument

  defaultMkDrvImpl =
    with final;
    import "${ path }/pkgs/stdenv/generic/make-derivation.nix" { inherit lib config; };

  overridableMkDrvImpl = mkDrvImpl: functor:
    ( stdenv: mkDrvArgs:
      ( ( mkDrvImpl stdenv ) mkDrvArgs ).overrideAttrs functor
    );

  overrideAttrsOnAllDrv = stdenv: functor:
    stdenv.override ( oldArgs: {
      mkDerivationFromStdenv = overridableMkDrvImpl
        ( oldArgs.mkDerivationFromStdenv or defaultMkDrvImpl ) functor;
    } );

  # demo
  useLLDLinker = stdenv:
    overrideAttrsOnAllDrv stdenv ( drvAttrs: {
      NIX_CFLAGS_LINK =
        toString ( drvAttrs.NIX_CFLAGS_LINK or "" ) + " -fuse-ld=lld";
    } );

}