{ config, ... }:

{

  home.file."cargo_config" = {
      source = ./config.toml;
      target =
        config.home.sessionVariables.CARGO_HOME + "/config.toml";
    };

}
