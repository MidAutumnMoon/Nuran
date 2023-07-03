{
    lib,
    sources,
    python3Packages,
}:

with python3Packages;

buildPythonApplication rec {

    pname = "watchgha";
    version = "unstable";

    format = "pyproject";

    inherit ( sources.${pname} ) src;


    nativeBuildInputs = [
        setuptools
    ];

    propagatedBuildInputs = [
        click
        exceptiongroup
        httpx
        rich
        trio
        dulwich
    ];


    meta = {
        mainProgram = "watch_gha_runs";
        homepage = "https://github.com/nedbat/watchgha/";
        license = lib.licenses.asl20;
    };

}
