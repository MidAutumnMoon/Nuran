{ lib, nixosConfig, pkgs, ... }:

let

  inherit ( pkgs ) writeText writers;

  inherit ( writers ) writeFish;

  allowedSigners = writeText "git-allowed-signers" ''
    me@418.im ${nixosConfig.nudata.pubkeys.self}
  '';

  watchghaWrapper = writeFish "watchgha" ''
    set -lx GITHUB_TOKEN "$( cat ${secrets.github_token.path} )"
    ${lib.getExe pkgs.watchgha} \
      "$( git remote get-url origin )" \
      "$( git rev-parse --abbrev-ref HEAD )"
  '';

  secrets = nixosConfig.sops.secrets;

in


{ imports = [

  ./delta.nix

]; xdg.configFile."git/config".text = ''

  [user]
    email = "me@418.im"
    name = "MidAutumnMoon"

  [merge]
    conflictstyle = "diff3"

  [diff]
    mnemonicPrefix = true

  [pull]
    rebase = "merges"

  [status]
    showUntrackedFiles = "all"

  [init]
    defaultBranch = "master"

  [core]
    quotePath = false

  [http]
    proxy = "${nixosConfig.networking.proxy.httpProxy}"

  [credential]
    helper = "store --file=${secrets."git_credentials".path}"

  [gc]
    auto = 0


  # Alias

  [alias]

    workflow-watch = "!${watchghaWrapper}"


  # Signing

  [user]
    signingKey = "${secrets."id_teapot.pub".path}"

  [gpg]
    format = "ssh"

  [gpg "ssh"]
    allowedSignersFile = "${allowedSigners}"

  [commit]
    gpgSign = true

  [tag]
    gpgSign = true

''; home.packages = with pkgs; [

  git

]; }
