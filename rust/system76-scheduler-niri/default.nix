{
    lib,
    tsuki,
}:

tsuki.rust.buildRustPackage rec {
    pname = "system76-scheduler-niri";
    version = "0.1.0";

    src = tsuki.workspace.selectSrc [ "system76-scheduler-niri" ];
    cargoLock = tsuki.workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = "${pname}";
}
