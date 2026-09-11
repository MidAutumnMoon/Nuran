# The pin driver: reassemble packages from captured store paths, without
# evaluating the flake that built them — the "fake derivation" trick,
# after fastpkgs / nixpkgs-multiverse.
#
# The outPath strings are given `{ path = true }` context, so Nix treats
# them as store objects it must substitute instead of plain text. There
# is no .drv behind a pin: a pin can only be fetched, never rebuilt.
# Realization requires the path to be substitutable (my own cache, where
# refresh-pin copied it) or already local.

{
    system,
    # pins.json: system -> package -> facts.
    pins,
}:

let

    # A store path belongs to one system: never serve a neighbour's.
    systemPins =
        pins.${system}
        or (throw ''
            pins: no capture for system ${system}
            (captured: ${toString (builtins.attrNames pins)})
        '');

    # The context entry is the whole trick: without it the string is
    # inert text no build can use.
    pinned =
        path:
        builtins.appendContext path {
            ${path}.path = true;
        };

    fake =
        name: pin:
        let
            outputNames = builtins.attrNames pin.outputs;
            defaultOutput =
                if pin.outputs ? out then "out" else builtins.head outputNames;
            outputPaths = builtins.mapAttrs (_: pinned) pin.outputs;
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
            # Say what works instead of an opaque missing-attribute
            # error: Nix asks for the drvPath of anything it is told to
            # build directly.
            drvPath = throw ''
                pins: ${pin.name} is pinned by store path and has no .drv —
                it can only be substituted, never rebuilt. Build an output
                instead (…${name}.${defaultOutput}); to move to a new
                version, run refresh-pin.
            '';
        };

in
builtins.mapAttrs fake systemPins
