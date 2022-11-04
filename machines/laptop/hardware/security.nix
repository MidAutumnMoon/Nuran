{

  security.tpm2.enable =
    true;

  users.users."teapot".extraGroups =
    [ "tss" ];

}
