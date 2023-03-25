{ nixosConfig, pkgs, ... }:

let

  allowedSigners = pkgs.writeText "git-allowed-signers" '''';

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

  [init]
    defaultBranch = "master"

  [core]
    quotePath = false

  [http]
    proxy = "${nixosConfig.networking.proxy.httpProxy}"

  [credential]
    helper = "store --file=${secrets."git_credentials".path}"


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