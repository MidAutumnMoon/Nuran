{
    lib,
    tsuki,
    workspace,
    rclone,
}:

tsuki.rust.buildRustPackage rec {
    pname = "phia_toolbox";
    version = "0.1.0";

    src = workspace.selectSrc [ "phia_toolbox" ];
    cargoLock = workspace.cargoLock;

    nativeBuildInputs = [
        tsuki.hooks.prefixCommaToBin
    ];

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    env = {
        CFG_RCLONE_PATH = lib.getExe rclone;
    };

    meta.mainProgram = pname;
}
