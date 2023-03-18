{
  callPackage,
  wrapMpv
}:

let

  vanillaMpv =
    wrapMpv ( callPackage ./unwrapped.nix {} ) { youtubeSupport = false; };

in

vanillaMpv.overrideAttrs ( oldAttrs: {

  buildCommand = oldAttrs.buildCommand + ''
    # umpv is totally useless
    rm --verbose \
      "$out/bin/umpv" \
      "$out/share/applications/umpv.desktop"
    '';

} )
