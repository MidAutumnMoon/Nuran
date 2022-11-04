{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
      # Networking tools
      dig mtr

      # Useful utils
      htop git screen
      file fd ripgrep
    ];


  programs =
    { fish.enable = true;
      neovim.enable = true;
    };

}
