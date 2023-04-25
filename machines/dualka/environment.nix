{ lib, ... }:

{

  documentation.enable = lib.mkForce false;

  documentation.man.enable = lib.mkForce false;

  sops.age.sshKeyPaths =
    [ "/etc/ssh/ssh_host_ed25519_key" ];

}
