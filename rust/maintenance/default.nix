{
    lib,
    tsuki,
    rclone,
}:

tsuki.rust.buildRustPackage rec {
    pname = "phia_maintenance";
    version = "0.1.0";

    src = tsuki.workspace.selectSrc [ "maintenance" ];
    cargoLock = tsuki.workspace.cargoLock;

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
