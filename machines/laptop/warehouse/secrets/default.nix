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


  # abcd portable service

  "ss_password" = forTeapot ./abcd.yml;

  "hy_obfs" = forTeapot ./abcd.yml;
  "hy_auth" = forTeapot ./abcd.yml;

  # "hy_ca_key" = forTeapot ./abcd.yml;
  "hy_ca_crt" = forTeapot ./abcd.yml;
  "hy_server_key" = forTeapot ./abcd.yml;
  "hy_server_crt" = forTeapot ./abcd.yml;


}; }
