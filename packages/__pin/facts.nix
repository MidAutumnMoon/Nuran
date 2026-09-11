# JSON-ready facts for one package set: everything the driver needs to
# reassemble a package without evaluating the flake that built it. The
# output is the per-system part of pins.json.
{
    names,
    packages,
}:

let

    # meta fields that cannot round-trip through JSON (functions, nested
    # derivations) are dropped rather than aborting the capture.
    jsonMeta =
        meta:
        builtins.listToAttrs (
            builtins.concatMap (k:
                let
                    v = builtins.tryEval (builtins.toJSON meta.${k});
                in
                if v.success then
                    [ { name = k; value = builtins.fromJSON v.value; } ]
                else
                    [ ]
            ) (builtins.attrNames meta)
        );

    capture =
        name:
        let
            p =
                packages.${name}
                or (throw ''
                    pins: input has no package "${name}" to capture
                    (available: ${toString (builtins.attrNames packages)})
                '');
        in
        {
            inherit (p) name pname;
            version = p.version or null;
            outputs = builtins.listToAttrs (
                map (o: { name = o; value = p.${o}.outPath; }) p.outputs
            );
            meta = jsonMeta (p.meta or { });
        };

in
builtins.listToAttrs (
    map (n: { name = n; value = capture n; }) names
)
