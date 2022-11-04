{

  description = "Nuran's lib";

  outputs = { self }: {

    lib = import ./.;

    initWith =
      nixpkgs: nixpkgs.lib.extend self.lib;

  };

}
