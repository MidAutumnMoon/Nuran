{ sources, lib, buildFishPlugin }:

buildFishPlugin rec {

  pname = "tide";

  inherit ( sources.${ pname } ) src version;

  fixupPhase = ''
    cp --verbose --recursive \
      'functions/tide' "$out/share/fish/vendor_functions.d"
    '';

  meta = {
      homepage = "https://github.com/IlanCosman/tide";
      license = lib.licenses.mit;
      description = "The ultimate Fish prompt.";
    };

}
