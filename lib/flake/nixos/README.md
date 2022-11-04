# mkSystems

Wraps `lib.nixosSystem`.

`mkSystems` function takes two attrsets,
the first one is taken as the default options,
which will be overridden by the second attrset.

This implements shared options across different
NixOS configurations.

Each attrset should be like:


```nix
rec {

  # The system type.
  #
  system = "x86_64-linux";

  localSystem = system;

  crossSystem = null;

  # Default NixOS modules.
  #
  # Should be a list of something that
  # nixpkgs' module system likes.
  #
  modules = [ ];

  # nixpkgs acts as nixpkgs.
  #
  nixpkgs = null;

  # For nixpkgs
  #
  overlays = [ ];

  # And also for nixpkgs.
  #
  config = { };

  # This is "_module.args".
  #
  arguments = { };

  # Where to find the machie's modules.
  #
  toplevel = null;

}
```

