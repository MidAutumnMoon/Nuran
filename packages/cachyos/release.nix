let

    pname = "linux-cachyos-gcc";
    version = "7.2.3";
    packageVersion = "7.2.3-1";

    architecture = "x86_64_v3";
    repository = "cachyos-v3";
    baseUrl = "https://cdn77.cachyos.org/repo/${architecture}/${repository}";

    package = packageName: hash: {
        inherit packageName hash;
        url = "${baseUrl}/${packageName}-${packageVersion}-${architecture}.pkg.tar.zst";
    };

in {

    inherit pname version packageVersion architecture;

    # `uname -r` and the module-tree directory. This comes from the package
    # contents; it must not be reconstructed from the package version.
    modDirVersion = "7.2.3-1-cachyos-gcc";

    kernel = package pname
        "sha256-PgdG8jXeiRG9Igity/J988K8XHYvqg97jyJE4IhbIaE=";

    headers = package "${pname}-headers"
        "sha256-4k+4jupBC6CkE2BTVQ1sfH368T0HinhHAERukI2BCdI=";

    # sha256 of usr/lib/modules/<version>/build/.config in `headers`.
    configHash = "3871eed42acf5818cf181a43c768c243b03f3f7667370adb2ed4da6eafa82c7f";

    isLTS = false;
    isZen = false;

}
