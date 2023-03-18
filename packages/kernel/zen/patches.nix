{
  sources,
  callPackage,
}:

# from CachyOS

( let

  cachyPatches =
    sources."cachyos-patches".src + "/6.2";

in [

  { name = "bore-scheduler";
    patch = "${cachyPatches}/sched/0001-bore.patch";
  }

] )
