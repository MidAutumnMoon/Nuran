{
  lib,
  sources,
  teapot,

  rustPlatform
}:

rustPlatform.buildRustPackage rec {

  pname = "mdbook-catppuccin";
  version = "unstable";

  inherit ( sources.${pname} ) src;

  cargoLock.lockFileContents =
    sources.${pname}."Cargo.lock";

  inherit ( teapot ) RUSTFLAGS;

  meta = {
      homepage = "https://github.com/catppuccin/mdBook";
      license = lib.licenses.mit;
    };

}

