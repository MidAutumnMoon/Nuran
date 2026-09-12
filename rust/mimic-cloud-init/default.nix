{
    tsuki,
}:

tsuki.rust.buildRustPackage rec {
    pname = "mimic-cloud-init";
    version = "0.1.0";

    src = tsuki.workspace.selectSrc [ "mimic-cloud-init" ];
    cargoLock = tsuki.workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = "mimic-cloud-init";
}
