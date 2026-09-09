# `linuxKernel.packagesFor` exposes these flags to out-of-tree module builds.
# Keep this aligned with nixpkgs' linux/kernel/common-flags.nix: absolute
# toolchain paths prevent module makefiles from depending on ambient PATH.
{
    lib,
    stdenv,
    buildPackages,
}:

[
    "CC=${lib.getExe stdenv.cc.cc}"
    "LD=${lib.getExe' stdenv.cc.bintools.bintools "${stdenv.cc.targetPrefix}ld"}"
    "AR=${lib.getExe' stdenv.cc "${stdenv.cc.targetPrefix}ar"}"
    "NM=${lib.getExe' stdenv.cc "${stdenv.cc.targetPrefix}nm"}"
    "STRIP=${lib.getExe' stdenv.cc.bintools.bintools "${stdenv.cc.targetPrefix}strip"}"
    "OBJCOPY=${lib.getExe' stdenv.cc "${stdenv.cc.targetPrefix}objcopy"}"
    "OBJDUMP=${lib.getExe' stdenv.cc "${stdenv.cc.targetPrefix}objdump"}"
    "READELF=${lib.getExe' stdenv.cc "${stdenv.cc.targetPrefix}readelf"}"
    "HOSTCC=${lib.getExe' buildPackages.stdenv.cc "${buildPackages.stdenv.cc.targetPrefix}cc"}"
    "HOSTCXX=${lib.getExe' buildPackages.stdenv.cc "${buildPackages.stdenv.cc.targetPrefix}c++"}"
    "HOSTAR=${lib.getExe' buildPackages.stdenv.cc.bintools "${buildPackages.stdenv.cc.targetPrefix}ar"}"
    "HOSTLD=${lib.getExe' buildPackages.stdenv.cc.bintools "${buildPackages.stdenv.cc.targetPrefix}ld"}"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
]
