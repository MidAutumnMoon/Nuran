{
  lib,
  sources,

  mkDerivation,
  appimageTools,

  autoPatchelfHook,

  qtmultimedia,
  openssl_1_1,
  libva,
  vulkan-loader,
  libpulseaudio,
  speexdsp,
  sndio,
}:

let

  pname = "yuzu-ea";

  sourceInfo = with sources."yuzu-ea-appimage"; {
      name = "${pname}-${version}";
      yuzuAppimage = src;
    };

  inherit ( sourceInfo ) name yuzuAppimage;

  libraryPath = lib.makeLibraryPath [
      vulkan-loader
      libpulseaudio
      speexdsp
      sndio
    ];

in

mkDerivation {

  inherit name;

  src = appimageTools.extract {
      name = "yuzu-appimage";
      src = yuzuAppimage;
    };

  installPhase = ''
    pushd "$src/usr"
    install -Dm755 "bin/yuzu" "$out/bin/yuzu"
    cp -rv "share" "$out/"
    '';

  qtWrapperArgs = [
      "--prefix LD_LIBRARY_PATH : ${libraryPath}"
      "--set QT_QPA_PLATFORM xcb"
    ];

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
      qtmultimedia
      openssl_1_1
      libva
    ];

  meta = {
      homepage = "https://yuzu-emu.org/";
      license = lib.licenses.gpl3;
      sourceProvenance =
        [ lib.sourceTypes.binaryNativeCode ];
    };

}
