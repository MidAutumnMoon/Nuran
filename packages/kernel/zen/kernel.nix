{
  lib,
  teapot,
  path,

  stdenv,
  stdenvTeapot,
  callPackage,
  buildPackages,

  linuxPackages_zen,

  ...
} @ pkgArgs:

# lld currently is usable to linker setup.elf
# (LLVM 15, kernel 6+) :(

let

  stdenvName = "stdenv";

in

( callPackage "${ path }/pkgs/os-specific/linux/kernel/zen-kernels.nix" ( pkgArgs // {

  stdenv = pkgArgs.${stdenvName};

  kernelPatches =
    linuxPackages_zen.kernel.kernelPatches
    ++ pkgArgs.kernelPatches or []
    ++ callPackage ./patches.nix {};

  structuredExtraConfig =
    import ../options { inherit lib; }
    // import ./options.nix { inherit lib; };

  # Hack to get clang into position meanwhile
  # avoiding causing massive rebuilds.
  #
  # If "configfile" is built using clang,
  # so that Kbuild will be able to detect LLVM
  # toolchain, making LTO etc. possible.
  buildPackages =
    buildPackages // { stdenv = buildPackages.${stdenvName}; };

} ) ).zen.overrideDerivation ( oldDrv: {

  LLVM =
    if pkgArgs.${stdenvName}.cc.isClang then 1 else null;

  preConfigure = oldDrv.preConfigure or "" + ''
    makeFlagsArray+=(
      KCFLAGS="${ toString teapot.baseOptimiz }"
    )
    '';

} )
