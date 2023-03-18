{
  neovim-unwrapped,

  lib,
  sources,
  teapot,

  stdenvTeapot,
  luajit_teapot,
  jemalloc,
}:


lib.onceride neovim-unwrapped

( _: {

  stdenv = stdenvTeapot;

  lua = luajit_teapot;

} )

( oldAttrs: {

  inherit ( sources."neovim" ) src;

  version = "nightly";


  NIX_CFLAGS_LINK = "-ljemalloc";


  buildInputs =
    oldAttrs.buildInputs ++ [ jemalloc ];

  patches =
    lib.removePatches
      [ "neovim-build-make-generated-source-files-reproducible.patch" ]
      oldAttrs.patches;

  preConfigure = oldAttrs.preConfigure or "" + ''
    cmakeFlagsArray+=(
      -DCMAKE_C_FLAGS="${ toString teapot.aggressiveOptimiz }"
    )
    '';


  stripAllList = [ "bin" ];

} )
