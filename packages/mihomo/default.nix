{
    mihomo,
    ...
}:

mihomo.override ( old: {
    buildGoModule = attrs:
        attrs // {
            env = attrs.env or {} // { GOAMD64 = "v3"; };
        }
        |> old.buildGoModule
    ;
} )
