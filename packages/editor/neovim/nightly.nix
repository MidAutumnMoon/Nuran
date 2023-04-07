{
  neovim-unwrapped,

  lib,
  sources,
  teapot,

  stdenvTeapot,
  luajit_teapot,
}:


lib.onceride neovim-unwrapped

( _: {

  stdenv = stdenvTeapot;

  lua = luajit_teapot;

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
