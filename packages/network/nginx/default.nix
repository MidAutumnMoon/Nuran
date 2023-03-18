{
  lib,
  teapot,
  callPackage,
  stdenvTeapot,

  nginxMainline,
  nginxModules,
}:

let

  teapotModules = [
    ];

  selectedModules = with nginxModules; [
      brotli
      moreheaders
    ];


  removeUselessFlagsFrom = lib.subtractLists [
      "--with-http_xslt_module"
      "--with-http_flv_module"
      "--with-http_mp4_module"
      "--with-http_random_index_module"
      "--with-http_image_filter_module"
      "--with-http_secure_link_module"
      "--with-http_degradation_module"
      "--with-http_stub_status_module"
      "--with-http_addition_module"
    ];

in

lib.onceride nginxMainline

( oldArgs: {

  stdenv = stdenvTeapot;

  modules = teapotModules ++ selectedModules;

} )

( oldAttrs: {

  patches = oldAttrs.patches ++ [
      ( callPackage ./ngx_http_tls_dyn_size.patch.nix {} )
    ];

  configureFlags =
    ( removeUselessFlagsFrom oldAttrs.configureFlags )
    ++ [
      "--without-http_uwsgi_module"
      "--without-http_scgi_module"
      "--without-http_grpc_module"
      "--without-http_memcached_module"
      "--without-http_browser_module"
      "--without-http_ssi_module"
    ];

  preBuild = oldAttrs.preBuild or "" + ''
    makeFlagsArray+=( CFLAGS="${ toString teapot.aggressiveOptimiz }" )
    '';

} )

