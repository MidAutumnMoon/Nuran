{

  programs.git.enable = true;

  programs.git.config =
    {
      # Workaroundabout #169193
      # where git breaks nixos-rebuild.
      safe.directory = "/home/teapot/Nix";
    };

}
