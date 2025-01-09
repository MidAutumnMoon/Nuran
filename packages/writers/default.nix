{
    lib,
    writers,

    buildPackages,
    ruby_teapot,
}:

let

    inherit ( writers )
        makeScriptWriter
    ;

in

writers // rec {

    # Usage
    #
    #   teapotRuby "ryyyy" {} ''
    #       puts "woiw"
    #   ''
    #
    #   or
    #
    #   teapotRuby "withPackages"
    #       { packages = ps: [ ps.toml ]; }
    #       ''puts "wow"''
    teapotRuby =
        name: { packages ? null }:
        let rbwp = ruby_teapot.withPackages packages; in
        let rb = if packages == null then ruby_teapot else rbwp; in
        name |> makeScriptWriter {
            interpreter = lib.getExe rb;
            check = "${lib.getExe buildPackages.ruby_teapot} -c";
        }
    ;

}
