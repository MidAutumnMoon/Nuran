{
  lib,

  callPackage,
  symlinkJoin,
  makeWrapper,

  name ? "neovim-nightly",
  unwrappedNeovim ? callPackage ./nightly.nix {},

  extraPrograms ? [],
}:

let

  inherit ( lib )
    makeBinPath
    concatStringsSep;

  xdgDataDirs = concatStringsSep ":" [
      "/run/current-system/sw/share"
    ];

  xdgConfigDirs = concatStringsSep ":" [
      "/etc/xdg"
      "/run/current-system/sw/etc/xdg"
    ];

in

symlinkJoin {

  inherit name;

  paths =
    [ unwrappedNeovim ];

  nativeBuildInputs =
    [ makeWrapper ];

  postBuild = ''
    rm -v "$out/bin/nvim"

    # nvim is smart enough to figure out his real
    # path, so no need to include the runtime in wrapper
    rm -r "$out/share/nvim"

    makeWrapper \
      "${ unwrappedNeovim }/bin/nvim" "$out/bin/nvim" \
      --inherit-argv0 \
      --prefix PATH ':' '${ makeBinPath extraPrograms }' \
      --set XDG_DATA_DIRS '${ xdgDataDirs }' \
      --set XDG_CONFIG_DIRS '${ xdgConfigDirs }'

    ln -s "$out/bin/nvim" "$out/bin/vi"
    ln -s "$out/bin/nvim" "$out/bin/vim"
    '';

  passthru.unwrapped = unwrappedNeovim;

  meta.mainProgram = "nvim";

}
