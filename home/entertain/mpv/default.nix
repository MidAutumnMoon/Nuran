{ pkgs, ... }:

{

  home.packages = [ pkgs.mpv_teapot ];

  xdg.configFile."mpv/input.conf".source = ./input.conf;

  xdg.configFile."mpv/mpv.conf".source = ./mpv.conf;

}
