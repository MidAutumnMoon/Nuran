{ config, ... }:

let

  teapot = config.users.users."teapot".name;

  forTeapot =
    path: { sopsFile = path; owner = teapot; };

in

{ sops.secrets = {

  # SSH keys

  "id_teapot" = forTeapot ./ssh.yml;
  "id_teapot.pub" = forTeapot ./ssh.yml;


  # git credentials & Github token whatever

  "github_token" = forTeapot ./git_token.yml;
  "git_credentials" = forTeapot ./git_token.yml;
  "nix_token_config" = forTeapot ./git_token.yml;

}; }
