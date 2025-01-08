{
    lib,
    stdenv,
    fetchFromGitHub,

    cmake,

    libjpeg,
}:

stdenv.mkDerivation {

    pname = "libyuv";
    version = "unstable";

    src = fetchFromGitHub {
        # unofficial mirror
        owner = "lemenkov";
        repo = "libyuv";
        rev = "cacaf42e97284107dc88502c8f0af9ac356d199b";
        hash = "sha256-sB5iCuc3+Dp9uVm2mUt4XhQ3zazsueEVNNw6uTMGTuQ=";
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
