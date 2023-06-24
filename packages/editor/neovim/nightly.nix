{
  neovim-unwrapped,

  lib,
  sources,
  teapot,

  stdenvTeapot,
}:


lib.onceride neovim-unwrapped

( _: {

  stdenv = stdenvTeapot;

} )

( oldAttrs: {

  inherit ( sources."neovim" ) src;

  version = "nightly";

  patches = [];

  preConfigure = oldAttrs.preConfigure or "" + ''
    cmakeFlagsArray+=(
      -DCMAKE_C_FLAGS="${ toString teapot.aggressiveOptimiz }"
    )
  '';

  stripAllList = [ "bin" ];

} )
