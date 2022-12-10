{ flakes, ... }:

{ nix.registry = {

  "short" = {
      from = { id = "p"; type = "indirect"; };
      to = { type = "path"; path = flakes.nixpkgs; };
    };

}; }
