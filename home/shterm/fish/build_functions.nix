{
  lib,
  runCommandLocal,
  pkgs
}:

toplevel:


let

  inherit ( lib ) getExe getBin;

  buildScript = ''
    mkdir --parent "$out"

    find ${ toplevel } \
      -type f \
      -name '*.fish' \
      -exec \
        cp -t "$out" {} \+

    for file in "$out"/*.fish
    do
      substituteAllInPlace "$file"
    done
    '';


in

runCommandLocal "fish-functions" ( with pkgs; {

  cli_ytdlp = getExe yt-dlp;

  cli_avifenc =
    "${ getBin libavif }/bin/avifenc";

} ) buildScript
