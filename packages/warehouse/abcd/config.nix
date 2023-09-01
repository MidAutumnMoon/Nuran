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

    # readSecret =
    #     name: lib.fileContents secrets.${name}.path;

    # copySecret =
    #     name: copyPathToStore secrets.${name}.path;

    readSecret =
        name: lib.fileContents ( secrets + "/${name}" );

    copySecret =
        name: copyPathToStore ( secrets + "/${name}" );

    # secrets = config.sops.secrets;

    secrets = /home/teapot/.local/state/secrets;

in

{
    dns_addr =
        config.nudata.services.dns.listen_addr;

    ss_password = readSecret "ss_password";
    ss_port_a = 39082;

    hy_domain = "io.99923b948eaf5bcd.io";
    hy_port = 40875;
    hy_obfs = readSecret "hy_obfs";
    hy_auth = readSecret "hy_auth";
    hy_cert = copySecret "hy_server_crt";
    hy_key = copySecret "hy_server_key";
}
