{
    lib
}:

let

    files = lib.filter
        ( p: ! lib.hasExtension "nix" p )
        ( lib.listAllFiles ./. );

in

builtins.listToAttrs (

    let
        nameNcontent = path:
            let name = builtins.baseNameOf path; in
            let content = lib.fileContents path; in
            lib.nameValuePair name content;
    in

    map nameNcontent files

) // {

    # attrpath = outfile_name
    manifest = {
        "caddy_teapot" = "caddy";
        "prvn-pkgs.pn-dnsproxy" = "dnsproxy";
    };

}
