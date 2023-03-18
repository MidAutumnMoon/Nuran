{
  lib,
  sources,
  runCommandLocal,
}:

let

  buildEnvs = {
      src = sources."graphite-cursors".src;
      version = "unstable";
    };

  buildEnvs.meta = {
      homepage = "https://github.com/vinceliuice/Graphite-cursors";
      license = lib.licenses.gpl3;
    };

  buildCommand = ''
    installDir="$out/share/icons"
    mkdir -p "$installDir"

    cp -rv "$src/dist-light"      "$installDir/Graphite-light-cursors"
    cp -rv "$src/dist-dark"       "$installDir/Graphite-dark-cursors"
    cp -rv "$src/dist-light-nord" "$installDir/Graphite-light-nord-cursors"
    cp -rv "$src/dist-dark-nord"  "$installDir/Graphite-dark-nord-cursors"
    '';

in

runCommandLocal "graphite-cursor-theme" buildEnvs buildCommand
