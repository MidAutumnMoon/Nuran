{ lib, firefox }:

lib.onceride firefox

( _: {

  extraPolicies =
    import ./policies.nix;

  extraPrefs =
    builtins.readFile ./autoconfig.js;

} )

( oldAttrs: {

  # 1) fake a timezone to enhance privacy protection

  buildCommand = oldAttrs.buildCommand + ''
    mv $out/bin/{firefox,.firefox-old-wrapped}
    makeWrapper $out/bin/{.firefox-old-wrapped,firefox} \
      --set TZ "Asia/Tokyo"
    '';
} )
