# Consumer view of pins.json. This deliberately has no dependency on the
# refresh manifest or its upstream substituters.
{
    system,
}:

let

    pins = builtins.fromJSON (builtins.readFile ./pins.json);

    # A store path belongs to one system: never serve a neighbour's.
    packages =
        pins.${system}
        or (throw ''
            pins: no packages for system ${system}
            (pinned systems: ${toString (builtins.attrNames pins)})
        '');

    # Give an output path constant string context. Nix will then realize
    # it through the consumer's ordinary substituters.
    pinned =
        path:
        builtins.appendContext path {
            ${path}.path = true;
        };

    hydrate =
        name: path:
        let
            out = pinned path;
        in {
            type = "derivation";
            inherit name out;
            pname = name;
            outputs = [ "out" ];
            outputName = "out";
            outPath = out;
            drvPath = throw ''
                pins: ${name} is pinned by store path and has no .drv —
                it can only be substituted, never rebuilt. Build its
                .out attribute; to move to a new version, run refresh-pin.
            '';
        };

in
builtins.mapAttrs hydrate packages
