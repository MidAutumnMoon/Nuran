lib:

{

    # brewNixOS :: attrset -> string | attrset -> [ module ] -> nixos
    brewNixOS = { pkgsBrew, modules ? [], arguments ? {}, }: system: toplevel:
        lib.nixosSystem {
            specialArgs = { inherit lib; };
            modules = [
                { nixpkgs.pkgs = pkgsBrew.${system}; }
                { _module.args = arguments; }
            ] ++ toplevel ++ modules;
        }
    ;

}
