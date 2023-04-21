lib:

let

  inherit ( lib )
    mapAttrs
    recursiveUpdate
    ;


  metaFor =
    nixosConfig: { meta = {
      nodeNixpkgs =
        mapAttrs ( _: n: n.pkgs ) nixosConfig;
      nodeSpecialArgs =
        mapAttrs ( _: n: n._module.specialArgs ) nixosConfig;
    }; };


  importModules =
    node: { imports = node._module.args.modules; };

  bodyFor =
    nixosConfig: mapAttrs ( _: n: importModules n ) nixosConfig;

in

{

  # adoptColmena :: attrset -> attrset -> attrset
  #
  # Transcode nixosConfigurations into Colmena format.
  #
  adoptColmena =
    nixosConfig: overrides:
      recursiveUpdate ( metaFor nixosConfig // bodyFor nixosConfig ) overrides;

}
