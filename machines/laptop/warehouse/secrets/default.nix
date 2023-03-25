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


  # git credentials

  "git_credentials" = forTeapot ./git_cred.yml;


}; }
