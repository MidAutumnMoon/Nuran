{
    lib,
    stdenv,
    fetchFromGitHub,

    cmake,

    libjpeg,
}:

stdenv.mkDerivation {

    pname = "libyuv";
    version = "0-unstable-2025-01-08";

    src = fetchFromGitHub {
        # unofficial mirror
        owner = "lemenkov";
        repo = "libyuv";
        rev = "84186e163af101fda62603a0871887975a6485a2";
        hash = "sha256-SMtCL8AY/7j+mZ5UUxNsKmqkCezdZ0PRkGfAeFinEnE=";
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
