{ lib, config, pkgs, ... }:

lib.condMod (config.programs.fzf.enable) {

  home.packages = with pkgs;
    [ fd ];

  programs.fzf = rec
    { defaultCommand =
        "fd --ignore --hidden --exclude '.git*/'";
      fileWidgetCommand =
        defaultCommand;
    };

}
