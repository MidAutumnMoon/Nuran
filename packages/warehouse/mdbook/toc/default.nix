{
  lib,
  sources,
  teapot,

  rustPlatform
}:

rustPlatform.buildRustPackage rec {

  pname = "mdbook-toc";
  version = "unstable";

  inherit ( sources.${pname} ) src;

  cargoLock.lockFileContents =
    sources.${pname}."Cargo.lock";

  inherit ( teapot ) RUSTFLAGS;

  meta = {
      homepage = "https://github.com/badboy/mdbook-toc";
      license = lib.licenses.mpl20;
    };

}

