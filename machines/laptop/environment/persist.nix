{ environment.persistence."/persist" = {

  directories = [
      "/etc/NetworkManager/system-connections"
    ];

  files = [
      "/etc/machine-id"

      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];

}; }
