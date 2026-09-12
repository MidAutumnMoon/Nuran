{
    tsuki,
    workspace,
}:

tsuki.rust.buildRustPackage rec {
    pname = "pin-driver";
    version = "0.1.0";

    src = workspace.selectSrc [ "pin-driver" ];
    cargoLock = workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = pname;
}
