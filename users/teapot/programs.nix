{ pkgs, ... }:

{

  home.packages = with pkgs; [
      file ripgrep fd
      rclone prime-offload
      wl-clipboard neofetch

      ruby_3

      firefox-teapot virt-manager
    ];


  programs =
    { # Editors
      neovim.enable = true;

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

      # Other Things
      fcitx5.enable = true;
    };


}

