{
  lib,
  nixosName,
  flake,

  copyPathToStore,
}:

let

  inherit ( flake.nixosConfigurations.${nixosName} )
    config
    ;

  readSecret =
    name: lib.fileContents secrets.${name}.path;

  copySecret =
    name: copyPathToStore secrets.${name}.path;

  secrets = config.sops.secrets;

in builtins.foldl' ( a: b: a // b ) {} [

{
  dns_addr =
    config.nudata.services.dnscrypt.listen_addr;
}

{
  ss_password = readSecret "ss_password";
  ss_port_a = 39080;
  ss_port_b = 39082;
}

{
  hy_domain = "io.99923b948eaf5bcd.io";
  hy_port = 40875;
  hy_obfs = readSecret "hy_obfs";
  hy_auth = readSecret "hy_auth";
  hy_cert = copySecret "hy_server_crt";
  hy_key = copySecret "hy_server_key";
}

]
