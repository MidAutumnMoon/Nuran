{ lib, pkgs, ... }:

{

  home.packages = with pkgs; [

      file
      ripgrep
      fd
      p7zip
      derputils

      rclone
      prime-offload
      wl-clipboard
      neofetch

      firefox_teapot
      virt-manager

    ];


  programs = {

      # Editors
      neovim.enable = lib.mkForce false;

      # Shells
      fish.enable = true;

      # Utils
      direnv.enable   = true;
      fzf.enable      = true;
      zoxide.enable   = true;

      # Generic Utils
      git.enable = true;

      # Graphical Utils
      kitty.enable = true;
      mpv.enable = true;

      # Security tools
      gpg.enable = true;

    };


}

