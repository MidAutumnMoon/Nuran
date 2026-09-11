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
            pins: no capture for system ${system}
            (captured: ${toString (builtins.attrNames pins)})
        '');

    # Give an output path constant string context. Nix will then realize
    # it through the consumer's ordinary substituters.
    pinned =
        path:
        builtins.appendContext path {
            ${path}.path = true;
        };

    hydrate =
        name: pin:
        let
            outputNames = map (output: output.name) pin.outputs;
            defaultOutput =
                if outputNames == [ ] then
                    throw "pins: ${name} has no outputs"
                else
                    builtins.head outputNames;
            outputPaths = builtins.listToAttrs (
                map (output: {
                    inherit (output) name;
                    value = pinned output.path;
                }) pin.outputs
            );
        in
        # Outputs first so derivation-critical attributes cannot be
        # shadowed by an output literally named "type" or "outPath".
        outputPaths
        // {
            type = "derivation";
            inherit (pin) name pname;
            version = pin.version or null;
            outputs = outputNames;
            outputName = defaultOutput;
            outPath = outputPaths.${defaultOutput};
            meta = pin.meta or { };
            drvPath = throw ''
                pins: ${pin.name} is pinned by store path and has no .drv —
                it can only be substituted, never rebuilt. Build an output
                instead (…${name}.${defaultOutput}); to move to a new
                version, run refresh-pin.
            '';
        };

in
builtins.mapAttrs hydrate packages
