{
  sources,
  lua
}:

luaSelf: luaPrev:

{

  inherit lua;

  moonscript = luaPrev.moonscript.overrideAttrs ( oldAttrs: {
      src = sources.${oldAttrs.pname}.src;
    } );

}
