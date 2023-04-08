{
  serviceName,
  config,

  lib,
  writeText,
  substituteAll,
  runCommand,

  hysteria,
  cue,
}:

rec {

  configCue = substituteAll {
    src = ./server.cue;
    inherit ( config )
      dns_addr
      hy_port
      hy_auth
      hy_obfs
      hy_cert
      hy_key
      ;
  };

  configFile = runCommand "hysteria.json" {} ''
    ${lib.getExe cue} export ${configCue} -o "$out"
  '';

  service = writeText "${serviceName}-hysteria.service" ''
    [Unit]
    Description = Hysteria
    After = network.target nss-lookup.target
    Wants = network.target

    [Service]
    Type = simple
    LimitNOFILE = 500000
    Nice = -10
    ExecStart = ${lib.getExe hysteria} server --config ${configFile}
    Restart = on-failure

    [Install]
    WantedBy = multi-user.target
    '';

}
