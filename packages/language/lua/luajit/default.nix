{
  self,
  luajit,

  lib,
  teapot,
  stdenvTeapot,
  callPackage,

  deterministicStringIds ? true
}:


lib.onceride luajit

( _: {

  stdenv = stdenvTeapot;

  packageOverrides =
    callPackage ../packages { lua = self; };

  inherit deterministicStringIds;

} )

( oldAttrs: {

  preBuild = oldAttrs.preBuild or "" + ''
    makeFlagsArray+=(
      CFLAGS="${ toString teapot.baseOptimiz }"
    )
    '';

} )
