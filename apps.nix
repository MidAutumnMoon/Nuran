{
    lib,
    pkgs,

    writeTextFile,

    home-manager,
}:

let

    # Not using writers.writeFish because of
    # it's slowness caused by checking phase
    fish = name: text: writeTextFile {
        inherit name;
        destination = "/bin/${name}";
        executable = true;
        text = ''
            #!${lib.getExe pkgs.fish} -PN
            ${text}
        '';
        meta.mainProgram = name;
    };

in

{

    # Wrapper of home-manager to make it "smarter".
    hm = fish "wow" ''
        set -l Action "switch"

        if [ -n "$argv[1]" ]
            set Action "$argv[1]"
        end

        ${lib.getExe home-manager} "$Action" \
            --flake ".#$hostname"
    '';

}
