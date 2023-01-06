with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

removePatches [ "system_rplugin_manifest.patch" ] pkgs.neovim-unwrapped.patches
