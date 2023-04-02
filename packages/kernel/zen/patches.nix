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

]
