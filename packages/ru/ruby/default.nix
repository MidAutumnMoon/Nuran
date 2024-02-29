{
    lib,
    callPackage,
    makeBinaryWrapper,

    ruby_3_3,
    defaultGemConfig,

    moreGemsConfig ? {},
}:

lib.onceride ruby_3_3

( _: {
    defaultGemConfig = defaultGemConfig // moreGemsConfig;
    jemallocSupport = true;
} )

( old: {

    nativeBuildInputs = old.nativeBuildInputs
        ++ [ makeBinaryWrapper ];

    postFixup = ( old.postFixup or "" ) + ''
        wrapProgram "$out/bin/ruby" \
            --prefix "RUBYLIB" ":" \
                "${placeholder "devdoc"}/lib/ruby/site_ruby" \
            --set-default "RUBY_YJIT_ENABLE" 1 \
            --prefix "MALLOC_CONF" "," "background_thread:true"
    '';

    passthru = old.passthru // {
        brewed = callPackage ./brewed.nix {};
    };

} )
