{
  lib,
  sources,
  teapot,

  rustPlatformTeapot,
}:

rustPlatformTeapot.buildRustPackage rec {

  pname = "derputils";

  version = "unstable";

  inherit ( sources.${ pname } ) src;

  cargoLock.lockFileContents =
    sources.${ pname }."Cargo.lock";


  inherit ( teapot ) RUSTFLAGS;

  meta = {
      homepage = "https://github.com/MidAutumnMoon/derputils";
      license = lib.licenses.mit;
    };

}

