{
  serviceName,
  config,

  lib,
  copyPathToStore,
  substituteAll,
  writeText,

  coredns,
}:

rec {

  blocklist = copyPathToStore ./blocklist;

  corefile = substituteAll {
    src = ./Corefile;
    inherit ( config ) dns_addr;
    inherit blocklist;
  };

  service = writeText "${serviceName}-coredns.service" ''
    [Unit]
    Description = coredns
    After = network-online.target
    Wants = network-online.target

    [Service]
    Type = simple
    ExecStart = ${lib.getExe coredns} -conf ${corefile}
    Restart = on-failure

    [Install]
    WantedBy = multi-user.target
  '';

}

