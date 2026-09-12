{
    tsuki,
}:

tsuki.rust.buildRustPackage rec {
    pname = "ci-driver";
    version = "0.1.0";

    src = tsuki.workspace.selectSrc [ "__ci" ];
    cargoLock = tsuki.workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = pname;
}
