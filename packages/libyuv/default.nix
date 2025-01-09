{
    lib,
    stdenv,
    fetchFromGitHub,

    cmake,

    libjpeg,
}:

stdenv.mkDerivation {

    pname = "libyuv";
    version = "0-unstable-2025-01-09";

    src = fetchFromGitHub {
        # unofficial mirror
        owner = "lemenkov";
        repo = "libyuv";
        rev = "e2c92b560ca76d640bef04715c3c26939e8ca519";
        hash = "sha256-oTT2LDdm23xjdYMtdd+i5NkyGp82jthk/S4C++JXXG8=";
    };

    nativeBuildInputs = [ cmake ];

    buildInputs = [ libjpeg ];

    postPatch = ''
        install -Dm644 ${./yuv.pc} $out/lib/pkgconfig/libyuv.pc
        substituteInPlace $out/lib/pkgconfig/libyuv.pc \
            --replace "@PREFIX@" "$out" \
            --replace "@VERSION@" "$version"
    '';

    meta = with lib; {
        homepage = "https://chromium.googlesource.com/libyuv/libyuv";
        description = "Library for YUV scaling";
        platforms = platforms.unix;
        license = licenses.bsd3;
    };
}
