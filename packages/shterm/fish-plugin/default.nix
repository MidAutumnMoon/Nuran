{ sources }:

fishSelf: fishSuper:

let

  callPackage =
    fishSelf.newScope { inherit sources; };

in

{

  tide =
    callPackage ./tide.nix {};

  puffer-fish =
    callPackage ./puffer-fish.nix {};

}
