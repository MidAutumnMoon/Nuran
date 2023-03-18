{ sources, lib, buildFishPlugin }:

buildFishPlugin rec {

  pname = "puffer-fish";
  version = "master";

  inherit ( sources.${ pname } ) src;

  meta = {
      homepage = "https://github.com/nickeb96/puffer-fish";
      license = lib.licenses.mit;
      description = "Text Expansions for Fish";
    };

}
