{ lib, config, ... }:

let

  punctuationDir =
    "${config.xdg.dataHome}/fcitx5/punctuation";

in

lib.condMod (config.programs.fcitx5.enable) {

  options.programs.fcitx5.enable =
    lib.mkEnableOption "MidAutumnMoon's fcitx5!";

  home.file =
    { "${punctuationDir}/punc.mb.zh_CN".source = ./punc.zh_CN;
      "${punctuationDir}/punc.mb.zh_HK".source = ./punc.zh_HK;
      "${punctuationDir}/punc.mb.zh_TW".source = ./punc.zh_TW;
    };

}
