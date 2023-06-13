{
  sources,
  callPackage,
}:

let

  cachyPatches =
    sources."cachyos-patches".src + "/6.3";

  patch =
    name: patch: { inherit name patch; };

in [

  ( patch "bore_sche" "${cachyPatches}/sched/0001-bore.patch" )

  ( patch "zstd-1.5.5" "${cachyPatches}/0011-zstd-import-1.5.5.patch" )

]
