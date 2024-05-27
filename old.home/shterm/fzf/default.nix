{ lib, config, pkgs, ... }:

{

  home.packages = with pkgs;
    [ fd ];

  programs.fzf = rec {
      enable = true;
      defaultCommand =
        "fd --ignore --hidden --exclude '.git*/'";
      fileWidgetCommand =
        defaultCommand;
    };

}
