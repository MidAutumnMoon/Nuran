{ lib, runCommandLocal, pkgs }:

let

  inherit (lib) getExe getBin;


  substituteEnv = with pkgs; {

      git = getExe git;

      avifenc = "${getBin libavif}/bin/avifenc";

      yt_dlp = getExe yt-dlp;

    };


in

runCommandLocal "fish-functions" substituteEnv ''
  mkdir --parent "$out"

  find ${./functions} \
    -type f \
    -iname '*.fish' \
    -exec \
      cp --dereference --target-directory "$out" '{}' \+

  for funcfile in "$out"/*.fish; do
    substituteAllInPlace "$funcfile"
  done
  ''
