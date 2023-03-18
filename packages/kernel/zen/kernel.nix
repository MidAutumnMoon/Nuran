{
  lib,
  teapot,
  path,

  stdenv,
  callPackage,
  buildPackages,

  linuxPackages_zen,

  ...
} @ pkgArgs:

# lld currently is usable to linker setup.elf
# (LLVM 14, kernel 6.1) :(

( callPackage "${ path }/pkgs/os-specific/linux/kernel/zen-kernels.nix" ( pkgArgs // {

  stdenv =
    stdenv;

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
  #
  # (keep in sync with kernel's stdenv selection)
  buildPackages =
    buildPackages // { stdenv = buildPackages.stdenv; };

} ) ).zen.overrideDerivation ( oldDrv: {

  preConfigure = oldDrv.preConfigure or "" + ''
    makeFlagsArray+=(
      KCFLAGS="${ toString teapot.baseOptimiz }"
    )
    '';

} )
