{
    lib,
    tsuki,
    workspace,
}:

tsuki.rust.buildRustPackage rec {
    pname = "system76-scheduler-niri";
    version = "0.1.0";

    src = workspace.selectSrc [ "system76-scheduler-niri" ];
    cargoLock = workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = "${pname}";
}
