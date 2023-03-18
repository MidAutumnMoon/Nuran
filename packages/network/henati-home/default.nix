{
  lib,
  stdenvNoCC,
  fetchzip,

  jre_minimal,
  jre_headless
}:

let

  version = "1.6.1";

  src = fetchzip {
      url = "https://repo.e-hentai.org/hath/HentaiAtHome_${version}.zip";
      sha256 = "sha256-a690bpznUEqe4Z6vn6QClUBToSqpcj3vPyklURZlgW0=";
      stripRoot = false;
    };

  headlessMinimalJre =
    jre_minimal.override {
        jdk = jre_headless;
        modules = [ "java.base" "jdk.crypto.ec" ];
      };

in

stdenvNoCC.mkDerivation ( drvSelf: {

  pname = "hentai-home";

  inherit src version;

  buildInputs = [ headlessMinimalJre ];

  lanuchScript = ''
    #!/bin/sh
    ${headlessMinimalJre}/bin/java \
      -Xms128m -Xmx2G \
      -XX:+UnlockExperimentalVMOptions \
      -XX:-UseG1GC \
      -XX:+UseShenandoahGC \
      -XX:+DisableExplicitGC \
      -XX:+AlwaysPreTouch \
      -jar "${placeholder "out"}/lib/${drvSelf.pname}/HentaiAtHome.jar"
    '';

  passAsFile = [ "lanuchScript" ];

  installPhase = ''
    mkdir --parent "$out"/{lib/${drvSelf.pname}/,bin/}
    install -Dm755 "$lanuchScriptPath" "$out/bin/${drvSelf.pname}"
    install -Dm644 "$src/HentaiAtHome.jar" "$out/lib/${drvSelf.pname}"
    '';

  passthru =
    { inherit headlessMinimalJre; };

  meta = {
      license = lib.licenses.gpl3;
      homepage = "https://e-hentai.org/";
      mainProgram = drvSelf.pname;
    };

} )
