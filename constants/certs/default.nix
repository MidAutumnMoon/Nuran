{ config, ... }:

let

  allowGroupRead = "0440";

  group = config.users.groups.keys.name;

in

{

  sops.secrets."418_fullchain" =
    { sopsFile = ./418.yml;
      mode = allowGroupRead;
      inherit group;
    };

  sops.secrets."418_key" =
    { sopsFile = ./418.yml;
      mode = allowGroupRead;
      inherit group;
    };

}
