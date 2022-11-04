lib: options:

let

  localSystem =
    { system = options.localSystem; };

  crossSystem =
    if options.crossSystem != null
    then { system = options.crossSystem; }
    else null;

  finalPkgs =
    import options.nixpkgs {
      inherit (options) config overlays;
      inherit localSystem crossSystem;
    };


  configureModule =
    { lib, ... }: {
      _module.args =
        options.arguments;
      nixpkgs =
        {
          inherit (options) config overlays;
          inherit localSystem crossSystem;
          pkgs =
            lib.mkIf (options.nixpkgs != null) finalPkgs;
        };
    };

  machineModule =
    import options.toplevel;

in

assert builtins.isPath options.toplevel;

lib.nixosSystem
  {

    specialArgs =
      {
        # nixpkgs' lib plus Nulib and
        # maybe something else.
        #
        # Why does it work?
        # nixpkgs/18a062b02d6eb382714187b06e3bfc3ba25ace78/lib/modules.nix#L183
        #
        inherit lib;
      };

    # The sole usage of "system" in lib.nixosSystem
    # is to initialize nixpkgs, which "finalPkgs"
    # had done.
    #
    # But this function needs a "system" argument
    # in pure eval mode, so ╮(￣▽￣)╭
    #
    system =
      options.localSystem;

    modules =
      [ configureModule machineModule ] ++ options.modules;
  }
