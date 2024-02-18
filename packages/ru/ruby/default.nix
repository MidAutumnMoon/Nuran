{
    lib,
    makeBinaryWrapper,
    ruby_3_3,
}:

lib.onceride ruby_3_3

( _: {
    jemallocSupport = true;
} )

( old: {

    nativeBuildInputs = old.nativeBuildInputs
        ++ [ makeBinaryWrapper ];

    postFixup = ( old.postFixup or "" ) + ''
        wrapProgram "$out/bin/ruby" \
            --prefix "RUBYLIB" ":" \
                "${placeholder "devdoc"}/lib/ruby/site_ruby" \
            --set-default "RUBY_YJIT_ENABLE" 1
    '';

} )
