{
    lib,
    tsuki,
    workspace,
    par2cmdline-turbo,
}:

tsuki.rust.buildRustPackage rec {
    pname = "localbinbox";
    version = "0.1.0";

    src = workspace.selectSrc [ "localbinbox" ];
    cargoLock = workspace.cargoLock;

    nativeBuildInputs = [
        tsuki.hooks.prefixCommaToBin
    ];

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    env = {
        CFG_PAR2 = lib.getExe' par2cmdline-turbo "par2";
    };
}
