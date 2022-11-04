{ lib, runCommandLocal, pkgs }:

let

  inherit (lib) getExe;

  substituteEnv = with pkgs;
    { git =
        getExe git;
      heif_enc =
        "${libheif}/bin/heif-enc";
      yt_dlp =
        getExe yt-dlp;
    };

in

runCommandLocal "fish-functions" substituteEnv ''
  mkdir --parent "$out"

  find ${./functions} \
    -type f \
    -iname '*.fish' \
    -exec \
      cp --dereference --target-directory "$out" '{}' \+

  for funcfile in "$out"/*.fish
  do
    substituteAllInPlace "$funcfile"
  done
  ''
