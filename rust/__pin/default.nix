{
    tsuki,
}:

tsuki.rust.buildRustPackage rec {
    pname = "pin-driver";
    version = "0.1.0";

    src = tsuki.workspace.selectSrc [ "__pin" ];
    cargoLock = tsuki.workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = pname;
}
