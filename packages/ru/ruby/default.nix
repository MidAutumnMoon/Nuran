{
    lib,
    callPackage,
    makeBinaryWrapper,

    ruby_3_3,
    defaultGemConfig,
    glibcLocalesUtf8,

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

    buildInputs = old.buildInputs
        ++ [ glibcLocalesUtf8 ];

    postFixup = ( old.postFixup or "" ) + ''
        wrapProgram "$out/bin/ruby" \
            --prefix "RUBYLIB" ":" \
                "${placeholder "devdoc"}/lib/ruby/site_ruby" \
            --prefix "MALLOC_CONF" "," "background_thread:true" \
            --set-default "RUBY_YJIT_ENABLE" 1 \
            --set-default LOCALE_ARCHIVE "$LOCALE_ARCHIVE"
    '';

    passthru = old.passthru // {
        inherit ( callPackage ./brews.nix {} )
            brewed for_dev
        ;
    };

} )
