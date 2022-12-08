{ flake, ... }:

{ nix.registry = {

  "short" = {
      from = { id = "p"; type = "indirect"; };
      to = { type = "path"; path = flake.nixpkgs; };
    };

}; }
