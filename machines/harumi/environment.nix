{ lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs;
    [ acme-sh ];

  documentation.enable =
    lib.mkForce false;

  documentation.man.enable =
    lib.mkForce false;


  sops.age.sshKeyPaths =
    [ "/persist/etc/ssh/ssh_host_ed25519_key" ];

  environment.persistence."/persist".files =
    [ "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];

}
