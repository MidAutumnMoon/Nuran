{ lib, config, ... }:

{

  users.mutableUsers =
    lib.mkForce false;

  users.users."root".openssh.authorizedKeys.keys =
    [ config.nudata.pubkeys.self ];

}
