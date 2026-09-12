{
    tsuki,
    workspace,
}:

tsuki.rust.buildRustPackage rec {
    pname = "ci-driver";
    version = "0.1.0";

    src = workspace.selectSrc [ "ci-driver" ];
    cargoLock = workspace.cargoLock;

    cargoBuildFlags = "-p ${pname}";
    doCheck = false;

    meta.mainProgram = pname;
}
