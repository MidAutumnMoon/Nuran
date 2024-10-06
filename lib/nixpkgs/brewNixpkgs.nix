lib:

let

    inherit ( builtins )
        mapAttrs
        removeAttrs
    ;

    inherit ( lib.nuran.trivial )
        eachSystem
    ;

    importEachSystem = nixpkgs: options:
        eachSystem ( system:
            import nixpkgs ( { inherit system; } // options )
        );

    # __functor :: attrset -> (attrset -> whatever) -> attrset
    __functor = self: fun:
        removeAttrs self [ "__functor" ]
        |> mapAttrs ( system: pkgs: fun pkgs )
    ;

in

{

    # brewNixpkgs :: nixpkgs -> nixpkgs option -> { `system` = pkgs }
    #   where `system` comes form [ "x86_64-linux" "aarch-darwin" ... ]
    #
    # Automatically import nixpkgs for commonly supported systems.
    #
    # Usage
    #
    #   Feed this function with `nixpkgs` and `nixpkgs options`, like:
    #   pkgsBrew = brewNixpkgs inputs.nixpkgs { allowUnfree = false; };
    #
    #   It gives back an attrset of systems mapped to imported nixpkgs, like:
    #   { # pkgsBrew
    #       "x86_64-linux" = <<pkgs of x86_64-linux>>;
    #       etc.;
    #       __functor;
    #   }
    #
    #   This process is called "brew", thus the function name :)
    #
    #   The `__functor` is a convenient function for iterating on all pkgs:
    #   packages = pkgsBrew ( p: { inherit (p) cowsay; } )
    #   -> { #packages
    #       "x86_64-linux" = { cowsay = <<drv>>; };
    #       etc.;
    #   }
    #
    #   The `__functor` will remove itself from the result.
    #
    #   This lines up quite nicely with the flake semantics.
    #
    # Tips
    #
    #   1) `system` can be accessed within each `pkgs`, e.g.
    #   pkgsBrew ( p: p.system ) -> { `system` = system string; }
    #
    brewNixpkgs = nixpkgs: options:
        ( importEachSystem nixpkgs options ) // { inherit __functor; };

}
