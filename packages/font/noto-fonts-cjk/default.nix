{
  lib,
  sources,

  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation ( drvSelf: {

  pname = "noto-fonts-cjk";

  inherit ( sources.${ drvSelf.pname } )
    src version;


  preferLocalBuild = true;

  nativeBuildInputs = [ unzip ];

  buildCommand = ''
    unzip "$src" -d .

    install -Dm444 --verbose \
      -t "$out/share/fonts/opentype/${ drvSelf.pname }" \
      NotoSansCJK-Light.ttc \
      NotoSansCJK-Regular.ttc \
      NotoSansCJK-Medium.ttc \
      NotoSansCJK-Bold.ttc \
    '';


  meta = {
      homepage = "https://github.com/googlefonts/noto-cjk";
      license = lib.licenses.ofl;
    };

} )
