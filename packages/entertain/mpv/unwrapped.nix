{
  mpv-unwrapped,

  lib,
  teapot,
  stdenvTeapot,
}:

lib.onceride mpv-unwrapped

( _: {

  stdenv = stdenvTeapot;

  cacaSupport = false;

  dvdnavSupport = false;

  javascriptSupport = false;

  openalSupport = false;

  screenSaverSupport = false;

  speexSupport = false;

  xineramaSupport = false;

  xvSupport = false;

  theoraSupport = false;

} )

( oldAttrs: {

  preConfigure = oldAttrs.preConfigure or "" + ''
    mesonFlagsArray+=(
      -Db_lto=true
      -Dc_args="${ toString teapot.aggressiveOptimiz }"
    )
    '';

} )
